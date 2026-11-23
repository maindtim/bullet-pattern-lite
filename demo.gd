extends Control
## Lite demo: dodge a pattern. Arrow keys / WASD move, R restarts, 1-2 switch preset.
## Same BulletPattern core you ship in your own game.

const PRESET_NAMES := ["Flower", "Shotgun"]
## [shape, count, speed, interval, spread, spin, accel, turn]
const PRESETS := {
	"Flower": [["ring", 16, 110.0, 0.6, 0.0, 14.0, 0.0, 0.0], ["spiral", 4, 150.0, 0.12, 0.0, 17.0, 0.0, 0.0]],
	"Shotgun": [["fan", 7, 220.0, 0.45, 50.0, 0.0, 0.0, 0.0]],
}

var pattern := BulletPattern.new()
var logic := DodgeLogic.new()
var bullets: Array = []
var t := -0.0001
var preset := 0
var origin := Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	load_preset(0)


func load_preset(i: int) -> void:
	preset = i
	pattern = BulletPattern.new()
	for r in PRESETS[PRESET_NAMES[i]]:
		var l := BulletPattern.make_layer(r[0], r[1], r[2], r[3])
		l.spread = r[4]; l.spin = r[5]; l.accel = r[6]; l.turn = r[7]
		pattern.add_layer(l)
	restart()


func restart() -> void:
	bullets.clear()
	t = -0.0001
	logic.reset()


func _process(dt: float) -> void:
	origin = Vector2(size.x / 2.0, 150.0)
	if Input.is_key_pressed(KEY_R):
		restart()
	for k in PRESET_NAMES.size():
		if Input.is_key_pressed(KEY_1 + k) and k != preset:
			load_preset(k)
	if not logic.is_over():
		var d := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
		logic.move(d, dt, Rect2(-size.x / 2.0 + 10.0, -120.0, size.x - 20.0, size.y - 60.0))
		var t1 := t + dt
		bullets.append_array(pattern.spawn(t, t1))
		t = t1
		var keep := []
		var r := Rect2(-origin, size).grow(40)
		for b in bullets:
			BulletPattern.step(b, dt)
			if r.has_point(b.pos):
				keep.append(b)
		bullets = keep.slice(0, 3000)
		logic.check(bullets, dt)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.05, 0.1))
	draw_circle(origin, 14.0, Color(0.9, 0.3, 0.5))
	for b in bullets:
		var d := (b.pos as Vector2).length() / 400.0
		draw_circle(origin + b.pos, 4.0, Color.from_hsv(fmod(0.95 - d * 0.5, 1.0), 0.6, 1.0))
	if logic.invuln <= 0.0 or int(logic.invuln * 10.0) % 2 == 0:
		var p := origin + logic.pos
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -12), p + Vector2(9, 9), p + Vector2(-9, 9)]), Color(0.5, 0.9, 1.0))
		draw_circle(p, 3.0, Color.WHITE)
	var f := ThemeDB.fallback_font
	draw_string(f, Vector2(14, 26), "Pattern: %s   Lives: %d   Graze: %d   Score: %d" % [PRESET_NAMES[preset], logic.lives, logic.graze, logic.score])
	draw_string(f, Vector2(14, size.y - 14), "Arrows move | 1-2 pattern | R restart")
	if logic.is_over():
		draw_string(f, origin + Vector2(-60, 60), "GAME OVER - press R")
