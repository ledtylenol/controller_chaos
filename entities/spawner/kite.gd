extends Entity
class_name Kite

@export var rot_coeff := 3.0
@export var speed := 2500
@export var await_thres := 1.0
@onready var sprite: Sprite2D = $Sprite2D

var target: Entity:
	set(v):
		if v and v != target:
			v.erased.connect(on_erase)
		target = v
var tween: Tween
var ct: Tween
var go := false
var time_alive := 0.0
var s := 1
var rot_vel = 0.0
var spawn_pos := Vector2.ZERO
func _ready() -> void:
	if randi() % 2:
		s = -1
	else:
		s = 1
	rot_vel = s * TAU * rot_coeff
	sprite.rotation = rot_vel * 10
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(sprite, "scale", Vector2.ONE, 3.0).from(Vector2.ZERO)
	spawn_pos = global_position
func _physics_process(delta: float) -> void:
	time_alive += delta * float(go)
	sprite.rotate(-rot_vel * delta * rot_coeff)
	rot_vel = move_toward(rot_vel, 0.0, s * rot_vel * delta * rot_coeff)
	if target: if not time_alive > await_thres:
		rotation = lerp_angle(rotation, global_position.angle_to_point(target.global_position), 1.0 - exp(-delta * 5))
	else:
		if velocity.length():
			velocity = velocity.lerp(velocity.normalized() * speed, 1.0 - exp(-delta * 5.0))
		else:
			velocity = velocity.move_toward(global_position.direction_to(target.global_position), delta * 50)
		var col = move_and_collide(velocity * delta)
		if col:
			var b = col.get_collider()
			if b is Triangle:
				b.hit(self, col.get_local_shape(), null)
				erased.emit(self)
				return
	else:
		if global_position.distance_to(spawn_pos) > 100:
			velocity = velocity.lerp(global_position.direction_to(spawn_pos) * speed, 1.0 - exp(-delta * 2.0))
		else:
			velocity = velocity.move_toward(Vector2.ZERO, delta * 1000)
		move_and_collide(velocity * delta)
	if time_alive > 5 :
		erased.emit(self)

func tween_color(new: Color, duration: float) -> void:
	if ct:
		ct.kill()
	ct = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	ct.tween_property(sprite, "modulate", new, duration)

func on_erase(_who: Entity) -> void:
	go = false
	time_alive = 0.0
	tween_color(Color.WHITE, 0.5)
