extends Node

@export var noise: FastNoiseLite
var game: World
var save: GameSave = GameSave.new()
var t := 0.0
var save_cooldown := 50.0
var loaded_chunks: Dictionary[Vector2i, Chunk] = {}
var c = load("res://global/chunk.tscn")
var chunk_count := 0
func _ready() -> void:
	if ResourceLoader.exists("user://save.googus"):
		save = ResourceLoader.load("user://save.googus")
func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode == KEY_R and event.is_pressed():
		game.reload_world()

func _process(delta: float) -> void:
	t += delta
	save_cooldown -= delta
	if save_cooldown < 0.0:
		save_cooldown = 50.0
		save_game()

func _physics_process(delta: float) -> void:
	chunk_count = 0
func save_game() -> void:
	ResourceSaver.save(save, "user://save.googus")

func spawn_chunk(pos: Vector2i) -> void:
	if loaded_chunks.has(pos):
		return
	var chunk = c.instantiate()
	chunk.position = Vector2(pos) * chunk.size
	loaded_chunks[pos] = chunk
	print("CHUNK SPAWNED")
	game.add_world_child(chunk)
