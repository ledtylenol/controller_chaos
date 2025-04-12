extends Entity
class_name Triangle
var tween: Tween
var size := 10.0
@export var shaker_curve: Curve

@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var sprite_shake: ShakerComponent2D = $Sprite2D/SpriteShake

var moving := false:
	set(value):
		if value != moving:
			if value: tween_select()
			else: tween_deselect()
		moving = value
class Collision extends RefCounted:
	func _init(_c: Entity, _s: Node2D, h_v: Vector2) -> void:
		collider = _c
		shape = _s
		hit_vel = h_v
	var collider: Entity
	var shape: Node2D
	var hit_vel: Vector2
var selected := false:
	set(v):
		if v != selected:
			if v:
				tween_select()
			else:
				tween_deselect()
		selected = v
func _ready() -> void:
	tween_deselect()
func _physics_process(delta: float) -> void:

	if velocity.length() > 10.0:
		rotation = lerp_angle(rotation, velocity.angle(), 1.0 - exp(-delta * 5))
	if not moving:
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-delta * 2))
	sprite_shake.intensity = shaker_curve.sample(velocity.length())
	var subdelt := delta / 5
	var hit_cols = []
	var avoidance_positions = detection_area.get_overlapping_areas().map(func(x): return x.global_position)
	for _i in 5:
		var away_dist = Vector2.ZERO
		for p in avoidance_positions:
			away_dist += p.direction_to(global_position)
			away_dist *= 0.5
		velocity = velocity.slerp((velocity.normalized() + away_dist).normalized() * velocity.length(), 1.0 - exp(-subdelt * 5))
		var col := move_and_collide(velocity * subdelt)
		if col:
			var collider = col.get_collider()
			var old_vel = velocity
			velocity = velocity.bounce(col.get_normal())
			if collider is Entity\
				and old_vel.length() > 200\
				and old_vel.angle_to(global_position.direction_to(collider.global_position)) < PI/12:
				if not collider in hit_cols.map(func(c): return c.collider):
					print(col.get_collider_shape())
					hit_cols.push_back(Collision.new(collider, col.get_collider_shape(), old_vel))
	
	
	for ent in hit_cols:
		ent.collider.hit(self, ent.shape, ent.hit_vel)
func push(d: Vector2) -> void:
	velocity += d
	velocity = velocity.limit_length(5000.0)

func tween_deselect() -> void:
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "modulate", Color(0.7, 0.7, 0.7, 0.7), .4)
func tween_select() -> void:
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "modulate", Color.AQUAMARINE, .4)
func hit(w: Entity, _shape: Node2D, _hv) -> void:
	health -= w.damage

func set_health(new: float) -> void:
	health = new
	if health < 0.0:
		erased.emit(self)
		if not selected:
			die()

func die() -> void:
	queue_free()
