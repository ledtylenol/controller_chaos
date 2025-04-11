extends Camera2D
class_name Player

@export var max_power := 50.0

@onready var select_area: Area2D = $SelectArea
@onready var col_shape: CollisionShape2D = $SelectArea/CollisionShape2D

var selected_entities: Array[Triangle] = []
var selecting_entities: Array = []
var z := 1.0:
	set(v):
		z = clampf(v, 0.1, 0.3)
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

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("left", "right", "up", "down")
	position += dir * delta * 1000
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
	for body in selected_entities:
		if not body: continue
		var h_dir := body.global_position.direction_to(homing_point)
		var angle = body.velocity.angle_to(h_dir)
		body.velocity = body.velocity.slerp(body.velocity.rotated(angle), 1.0 - exp(-delta))
	
func _draw() -> void:
	if selecting:
		print("DRAWING")
		draw_rect(Rect2(start_local, get_local_mouse_position() - start_local), Color.WHITE, false, 5)
		draw_rect(Rect2(start_local, get_local_mouse_position() - start_local), Color(0.1, 0.1, 0.7, 0.6), true)

	if dragging:
		draw_line(drag_start, get_local_mouse_position(), Color.WHITE, log(drag_start.distance_squared_to(get_local_mouse_position())))
	if not selected_entities.is_empty():
		draw_circle(homing_point, 10, Color.RED)
func _process(delta: float) -> void:
	zoom = lerp(zoom, Vector2(z, z), 1.0 - exp(-delta * 5))
	queue_redraw()
func _input(event: InputEvent) -> void:
	z += 0.1 * Input.get_axis("zoom_out", "zoom_in")
	if event.is_action("interact"):
		selecting = event.is_pressed() and selected_entities.is_empty()
		dragging = event.is_pressed() and not selected_entities.is_empty()
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
	var diff_delta = ((get_local_mouse_position() - drag_start)).limit_length(max_power)
	if diff_delta.length() < 10:
		homing_point = get_global_mouse_position()
	for ent in selected_entities:
		if ent:
			ent.push(-diff_delta)

func initiate_select() -> void:
	selected_entities.clear()
	select_start = get_global_mouse_position()
	start_local = get_local_mouse_position()
	select_area.set_deferred("monitoring", true)

func end_select() -> void:
	for body in select_area.get_overlapping_bodies():
		if body is Triangle:
			selected_entities.append(body)
			body.selected = true
	select_area.set_deferred("monitoring", false)
	print("select ended")

func deselect_entities() -> void:
	for en in selected_entities:
		if en:
			print(en)
			en.selected = false
	selected_entities.clear()
