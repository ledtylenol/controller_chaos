extends Node

@onready var anim: AnimationPlayer = $"../Anim"
@onready var anim_tree: AnimationTree = $"../AnimTree"


func ouch() -> void:
	anim.stop()
	anim.play("ouch", -1, 1.0)
