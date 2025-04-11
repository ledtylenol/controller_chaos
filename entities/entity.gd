extends CharacterBody2D
class_name Entity

func push(d: Vector2) -> void:
	pass

func hit(who: Entity, shape: Node2D, h_v: Vector2) -> void:
	print("HIT %s %s" % [who, shape])
