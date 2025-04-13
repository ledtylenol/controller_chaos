extends Area2D
class_name ConvertArea



@onready var timer: Timer = $Timer
@onready var sound_on: AudioStreamPlayer2D = $SoundOn
@onready var sound_off: AudioStreamPlayer2D = $SoundOff
@onready var collision_shape: CollisionShape2D = $CollisionShape

var tween: Tween
var active := false
var alpha := 0.0
signal minion_found(tr: Triangle)
func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var col_1 := Color.ALICE_BLUE
	col_1.a = alpha
	var col_2 := Color.AQUAMARINE
	col_2.a = alpha
	draw_circle(Vector2.ZERO, collision_shape.shape.radius * 1.05 * alpha * 5, col_1, false, 10)
	draw_circle(Vector2.ZERO, collision_shape.shape.radius * 1.05 * alpha * 5, col_2, true)
func _input(event: InputEvent) -> void:
	if event.is_action("shift"):
		if event.is_pressed() and not active:
			active = true
			tween_start()
		elif not event.is_pressed() and active:
			active = false
			tween_end()
func _physics_process(delta: float) -> void:
	if active:
		for tr in get_overlapping_bodies():
			if tr is Minion and tr.wild:
				minion_found.emit(tr)

func tween_start() -> void:
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "alpha", 0.2, 0.5)
	sound_on.play()

func tween_end() -> void:
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "alpha", 0.0, 0.5)
	sound_off.play()
