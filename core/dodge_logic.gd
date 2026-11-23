class_name DodgeLogic
extends RefCounted
## Pure rules of the dodge demo: player movement, hit detection with graze, score.

const PLAYER_RADIUS := 4.0
const BULLET_RADIUS := 4.0
const GRAZE_RADIUS := 16.0

var pos := Vector2(0, 220)
var speed := 230.0
var lives := 3
var score := 0
var graze := 0
var invuln := 0.0


func move(dir: Vector2, dt: float, bounds: Rect2) -> void:
	pos += dir.normalized() * speed * dt if dir != Vector2.ZERO else Vector2.ZERO
	pos = Vector2(clampf(pos.x, bounds.position.x, bounds.end.x), clampf(pos.y, bounds.position.y, bounds.end.y))


## Checks bullets (positions relative to the same origin as `pos`). Returns indices of bullets that hit.
func check(bullets: Array, dt: float) -> Array:
	invuln = maxf(0.0, invuln - dt)
	var hits := []
	for i in bullets.size():
		var d := ((bullets[i].pos as Vector2) - pos).length()
		if d <= PLAYER_RADIUS + BULLET_RADIUS:
			hits.append(i)
		elif d <= GRAZE_RADIUS and not bullets[i].get("grazed", false):
			bullets[i]["grazed"] = true
			graze += 1
			score += 10
	if not hits.is_empty() and invuln <= 0.0 and lives > 0:
		lives -= 1
		invuln = 1.5
	score += int(dt * 100.0) if lives > 0 else 0
	return hits


func is_over() -> bool:
	return lives <= 0


func reset() -> void:
	pos = Vector2(0, 220)
	lives = 3
	score = 0
	graze = 0
	invuln = 0.0
