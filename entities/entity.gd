extends CharacterBody2D
class_name Entity
@export var damage := 0.5
@export var health := 3.0:
	set = set_health

signal erased(who: Entity)
func push(d: Vector2) -> void:
	pass

func hit(who: Entity, shape: Node2D, h_v: Vector2) -> void:
	print("HIT %s %s" % [who, shape])

func set_health(new: float) -> void:
	health = new
