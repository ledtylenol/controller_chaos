class_name AnimatedSprite extends Sprite2D

@export var rest_position :Marker2D

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if rest_position:
		position = lerp(position, rest_position.position, 1.0 * delta)
