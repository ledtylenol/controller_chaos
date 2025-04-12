extends Sprite2D
class_name Ghost
var tween: Tween
var vel := Vector2.ZERO
func _ready() -> void:
	var angle = randf_range(-PI, PI)
	vel = Vector2(cos(angle), sin(angle)) * randf_range(50, 300)
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	position += vel * delta
	vel *= 0.9
