class_name AnimatedSprite extends Sprite2D

@export var rest_position :Marker2D
@onready var second_order_dynamics: SecondOrderDynamics = $SecondOrderDynamics

func _ready() -> void:
	second_order_dynamics.init2(global_position)

func _physics_process(delta: float) -> void:
	if rest_position:
		global_position = second_order_dynamics.update(global_position, \
		rest_position.global_position, delta)[0]
