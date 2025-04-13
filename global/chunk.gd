@tool
extends Area2D
class_name Chunk
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var size: Vector2:
	set(value):
		if collision_shape_2d:
			collision_shape_2d.shape.size = value
		size = value
@export var density := 10
var children: Array[Node]
var scene_arr = [load("res://entities/pentagon/pentagon.tscn"), load("res://entities/spawner/spawner.tscn")]
var chunk_pos:
	get:
		return Vector2i(global_position / size)
var active := false:
	set(value):
		active = value
var spawned := false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	Global.chunk_count += 1
func activate() -> void:
	if Engine.is_editor_hint():
		return
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	active = true
	if spawned: return
	var step_w = size.x / density
	var step_h = size.y / density
	for i in range(-size.x / 2, size.x / 2, step_w):
		for j in range(-size.y / 2, size.y / 2, step_h):

			spawn_random(Vector2(i, j))
	spawned = true
	print("chunk at %s activated" % chunk_pos)
func spawn_random(pos: Vector2) -> void:
	var i: int
	match Global.noise.get_noise_2d(pos.x, pos.y):
		var x when x < 0.3:
			return
		var x when x < 0.8:
			i = 0
		_: i = 1
	var inst =  scene_arr[i].instantiate()
	inst.position = pos
	inst.rotate(randf_range(-PI, PI))
	add_child(inst)
func deactivate() -> void:
	active = false
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	print("chunk at %s deactivated" % chunk_pos)
