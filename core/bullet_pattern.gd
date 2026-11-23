class_name BulletPattern
extends RefCounted
## A pattern = list of layers. Each layer emits bullets in a shape, repeats over time.
## Pure data + math: spawn(t0, t1) returns bullet dicts {pos, vel, accel, turn}; step() advances them.
## Lite version: ring, fan and spiral shapes. The full Bullet Pattern Designer adds the wave shape,
## a visual editor, JSON export/import and validation.

const SHAPES := ["ring", "fan", "spiral"]

var layers: Array = []


static func make_layer(shape := "ring", count := 12, speed := 120.0, interval := 0.5) -> Dictionary:
	return {
		"shape": shape, "count": count, "speed": speed, "interval": interval,
		"spread": 60.0, "spin": 20.0, "accel": 0.0, "turn": 0.0, "offset": 0.0,
	}


func add_layer(layer: Dictionary) -> void:
	layers.append(layer)


## Angles (degrees) for one emission of a layer; `n` is the emission index (drives spin).
static func angles(layer: Dictionary, n: int) -> Array:
	var out := []
	var c := int(layer.count)
	var off := float(layer.offset)
	match layer.shape:
		"ring":
			for k in c:
				out.append(off + 360.0 * k / c + float(layer.spin) * n)
		"fan":
			var s := float(layer.spread)
			for k in c:
				out.append(off - s / 2.0 + (s * k / (c - 1) if c > 1 else s / 2.0))
		"spiral":
			out.append(off + float(layer.spin) * n)
			for k in range(1, c):
				out.append(off + float(layer.spin) * n + 360.0 * k / c)
	return out


## Bullets spawned by every layer in the window (t0, t1].
func spawn(t0: float, t1: float) -> Array:
	var out := []
	for l in layers:
		var iv := float(l.interval)
		var n0 := int(floor(t0 / iv)) + 1 if t0 >= 0.0 else 0
		var n := n0
		while n * iv <= t1:
			if n * iv > t0 or (t0 < 0.0 and n == 0):
				for a in angles(l, n):
					var r := deg_to_rad(a)
					out.append({
						"vel": Vector2(cos(r), sin(r)) * float(l.speed),
						"pos": Vector2.ZERO,
						"accel": float(l.accel),
						"turn": float(l.turn),
					})
			n += 1
	return out


static func step(b: Dictionary, dt: float) -> void:
	var v: Vector2 = b.vel
	var sp := v.length()
	if b.turn != 0.0:
		v = v.rotated(deg_to_rad(b.turn) * dt)
	if b.accel != 0.0:
		sp = max(0.0, sp + b.accel * dt)
		v = v.normalized() * sp
	b.vel = v
	b.pos += v * dt
