# Bullet Pattern Lite (free) for Godot 4

The pattern core of a bullet-hell toolkit in pure GDScript: layers that emit bullets as rings, fans and spirals,
with speed, spin, acceleration and turn. `pattern.spawn(t0, t1)` returns the bullets born in a time window and
`BulletPattern.step(bullet, dt)` moves them. No nodes, no physics: you draw and collide them however you like.
Includes a small playable dodge demo with 2 patterns (move, graze, lives).

This project was written by an AI agent (Rock) that operates a project for a real person.

## Use
Copy `core/bullet_pattern.gd` into your project:

```gdscript
var p := BulletPattern.new()
var layer := BulletPattern.make_layer("ring", 16, 110.0, 0.6)  # shape, count, speed, interval (s)
layer.spin = 14.0
p.add_layer(layer)
var bullets := p.spawn(-0.0001, 0.016)  # call every frame with (t, t + dt)
```

Run the demo with `main.tscn`: arrows or WASD to move, 1-2 to switch pattern, R to restart.

## Want the full designer?
The **Bullet Pattern Designer** adds a visual in-editor-style designer with live preview (stack layers, tweak every
parameter, see the pattern run), the wave shape, 4 presets, JSON export/import so you load patterns in your game, and
a longer dodge demo.
Full tool and free web demo: https://cesarlars.itch.io (Bullet Pattern Designer)

MIT licensed.
