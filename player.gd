extends Entity
class_name Player

@export var max_power := 50.0

@onready var select_area: Area2D = $SelectArea
@onready var col_shape: CollisionShape2D = $SelectArea/CollisionShape2D
@onready var target_area: Area2D = $TargetArea

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
	position += dir * delta * 1000
	target_area.global_position = get_global_mouse_position()
	if selecting:
		var new_bodies = select_area.get_overlapping_bodies().filter(func(b): return b is Triangle)
		for body in selecting_entities:
			if not body:
				continue
			if not body in new_bodies:
				body.selected = false
		for body in new_bodies:
			body.selected = true
		selecting_entities = new_bodies 
		var size := Rect2(select_start, get_global_mouse_position() - select_start).size
		col_shape.shape.size = abs(size)
		select_area.global_position = get_global_mouse_position() - size / 2
	if homing_target:
		homing_point = homing_target.global_position
		for b in selected_entities:
			if b:
				if b.velocity.length():
					b.velocity = b.velocity.lerp(b.velocity.normalized() * 5000, 1.0 - exp(-delta * 5))
				else:
					b.velocity = b.velocity.move_toward(b.global_position.direction_to(homing_point), 10)
				var h_dir := b.global_position.direction_to(homing_point)
				var angle = b.velocity.angle_to(h_dir)
				b.velocity = b.velocity.slerp(b.velocity.rotated(angle), 1.0 - exp(-delta * 9))
	else:
		homing_point = global_position
		for b in selected_entities:
			if b:
				if b.global_position.distance_to(global_position) > 500:
					if b.velocity.length():
						b.velocity = b.velocity.lerp(b.velocity.normalized() * 1000, 1.0 - exp(-delta * 5))
					else:
						b.velocity = b.velocity.move_toward(b.global_position.direction_to(homing_point), 10)
				var h_dir := b.global_position.direction_to(homing_point)
				var angle = b.velocity.angle_to(h_dir)
				b.velocity = b.velocity.slerp(b.velocity.rotated(angle), 1.0 - exp(-delta * 9))

	
func _draw() -> void:
	if selecting:
		draw_rect(Rect2(start_local, get_local_mouse_position() - start_local), Color.WHITE, false, 5)
		draw_rect(Rect2(start_local, get_local_mouse_position() - start_local), Color(0.1, 0.1, 0.7, 0.6), true)

	if not selected_entities.is_empty():
		draw_circle(homing_point, 10, Color.RED)
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
	if event.is_action("deselect") and event.is_pressed():
		deselect_entities()
		dragging = false
		selecting = false
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

func deselect_entities() -> void:
	for en in selected_entities:
		if en:
			en.selected = false
			en.erased.disconnect(on_erased)
	for en in selecting_entities:
		if en:
			en.selected = false
	homing_target = null
	selected_entities.clear()
	selecting_entities.clear()
	initiate_select()

func on_erased(t: Triangle) -> void:
	if t in selected_entities: selected_entities.erase(t)
	t.queue_free()
