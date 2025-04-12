extends Entity
class_name Player

@export var max_power := 50.0
@export var speed := 5000.0
@export var triangle_speed := 2500.0
@export var distance_thres := 200.0
@onready var select_area: Area2D = $SelectArea
@onready var col_shape: CollisionShape2D = $SelectArea/CollisionShape2D
@onready var target_area: Area2D = $TargetArea
@onready var sprite: SpriteHolder = $Sprite

const TRIANGLE = preload("res://entities/triangle/triangle.tscn")
var selected_entities: Array[Triangle] = []
var selecting_entities: Array = []
var homing_target: Entity

var dragging := false:
	set(v):
		if v != dragging:
			if v:
				initiate_drag()
			else:
				end_drag()
		dragging = v
var selecting := false:
	set(v):
		if v != selecting:
			if v:
				initiate_select()
			else:
				end_select()
		selecting = v

var select_start := Vector2.ZERO
var start_local := Vector2.ZERO
var drag_start := Vector2.ZERO
var homing_point := Vector2.ZERO
func _ready() -> void:
	Global.game.player = self

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("left", "right", "up", "down")
	if dir:
		velocity = velocity.lerp(dir * 5000, 1.0 - exp(-delta * 10))
	else:
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-delta * 20))
	handle_minions(delta)
	move_and_slide()
func handle_minions(delta: float) -> void:
	if Input.is_action_pressed("interact"):
		var mouse_pos := get_global_mouse_position()
		for m in selected_entities.filter(is_instance_valid):
			if m.global_position.distance_to(mouse_pos) > distance_thres:

				m.velocity = m.velocity.lerp(m.velocity.normalized() * triangle_speed * 2, \
												1.0 - exp(-delta * 5))
				m.velocity = m.velocity.slerp(m.global_position.direction_to(mouse_pos), \
												1.0 - exp(-delta * 10))
				m.moving = true
			else:
				m.moving = false
	else:
		for m in selected_entities.filter(is_instance_valid):
			if m.global_position.distance_to(global_position) > distance_thres:
				m.velocity = m.velocity.lerp(m.velocity.normalized() * triangle_speed, \
												1.0 - exp(-delta * 5))
				m.velocity = m.velocity.slerp(m.global_position.direction_to(global_position), \
												1.0 - exp(-delta * 10))
				m.moving = true
			else:
				m.moving = false
func _draw() -> void:
	#todo
	pass
func _process(_delta: float) -> void:

	queue_redraw()
func _input(event: InputEvent) -> void:
	if event.is_action("interact"):
		selecting = event.is_pressed() and selected_entities.is_empty()
		dragging = event.is_pressed() and not selected_entities.is_empty()
		if dragging:
			var bs = target_area.get_overlapping_bodies()
			var last_dist = INF
			if not bs.is_empty(): for bod in bs:
				var new_dist = get_global_mouse_position().distance_to(bod.global_position)
				if new_dist < last_dist:
					homing_target = bod
					last_dist = new_dist

	if event.is_pressed() and event is InputEventKey and event.keycode == KEY_Q:
		var t = TRIANGLE.instantiate()
		t.position = get_global_mouse_position()
		Global.game.add_world_child(t)
		selected_entities.push_back(t)
func initiate_drag():
	var i := 0
	for e in selected_entities:
		if e:
			i+= 1
	if i == 0:
		dragging = false
		return
	drag_start = get_local_mouse_position()
	
func end_drag() -> void:
	pass

func initiate_select() -> void:
	selected_entities.clear()
	select_start = get_global_mouse_position()
	start_local = get_local_mouse_position()
	select_area.set_deferred("monitoring", true)

func end_select() -> void:
	for body in selecting_entities:
		if body is Triangle:
			selected_entities.append(body)
			body.erased.connect(on_erased)
			body.selected = true
	select_area.set_deferred("monitoring", false)
	print("select ended")


func on_erased(t: Triangle) -> void:
	if t in selected_entities: selected_entities.erase(t)
	t.queue_free()

func hit(who: Entity, shape: Node2D, h_v: Vector2) -> void:
	if sprite.shaker.is_playing:
		sprite.shaker.force_stop_shake()
	sprite.shaker.play_shake()
