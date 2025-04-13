extends Node

@onready var anim: AnimationPlayer = $"../Anim"
@onready var anim_tree: AnimationTree = $"../AnimTree"


func ouch() -> void:
	anim.stop()
	anim.play("ouch", -1, 1.0)

func look_at( look_at_position:Vector2 ) -> void:
	# Math I don't know how to do
	
	# Do animation
	anim.stop()
	anim.play("look_at", -1, 1.0)
