extends Node2D

@export var available_rect: Rect2
@export var noise: FastNoiseLite
@export var val_threshold := 0.9
@export var density := 100
@export var player: Player
func _ready() -> void:
	for i in range(-1, 2):
		for j in range(-1, 2):
			Global.spawn_chunk(Vector2i(i, j))
			Global.loaded_chunks[Vector2i(i, j)].activate()
