extends Node
class_name World
@onready var world_2d: World2DRoot = $World2D
@onready var ui: UIRoot = $UI
@export var world_2d_packed: PackedScene
var ui_packed: PackedScene
var player: Player
func _enter_tree() -> void:
	Global.game = self

func change_world(new: PackedScene) -> void:
	if world_2d_packed != new: 
		world_2d_packed = new
	for child in world_2d.get_children(): child.queue_free()
	var new_scene = new.instantiate()
	world_2d.add_child(new_scene)

func instantiate_world(sc: PackedScene) -> void:
	world_2d.add_child(sc.instantiate())

func add_world_child(c: Node) -> void:
	world_2d.add_child(c)

func change_UI(new: PackedScene) -> void:
	for child in ui.get_children(): child.queue_free()
	var new_sc = new.instantiate()
	ui.add_child(new_sc)

func reload_world() -> void:

	change_world(world_2d_packed)
