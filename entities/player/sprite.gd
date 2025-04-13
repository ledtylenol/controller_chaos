extends Node2D
class_name SpriteHolder
@onready var shaker: ShakerComponent2D = $ShakerComponent2D
@onready var sprite_face_animator :Node = $SpriteFaceAnimation

func _physics_process(delta: float) -> void:
	rotation = lerp_angle(rotation, global_position\
				.angle_to_point(get_global_mouse_position()), 1.0 - exp(-delta * 5))
	for child in get_children(): 
		if child is AnimatedSprite:
			child.rotation = rotation + child.rest_position.rotation
