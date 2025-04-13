extends Entity
class_name Spawner

@export var kite_count := 20
@export var dist_low := 100.0
@export var dist_high := 300.0
@export var dist_thres := 2500.0

@onready var timer: Timer = $Timer
@onready var detection_area: Area2D = $DetectionArea
@onready var shake: ShakerComponent2D = $Shake
@onready var sprite: Sprite2D = $Sprite2D

var k_sc = load("res://entities/spawner/kite.tscn")
var targets: Array[Node2D] = []
var kites: Array[Kite] = []
var rot_vel := 0.0
var rot_target := 0.0
var active := true
func _ready() -> void:
	timer.timeout.connect(on_timeout)
	detection_area.area_entered.connect(on_enter)
	detection_area.area_exited.connect(on_exit)
func _physics_process(delta: float) -> void:
	var p = Global.game.player
	if not targets.is_empty():
		rot_target = TAU * 3.883
		shake.intensity = 1.0
	else:
		shake.intensity = 0.0
		rot_target = 0.0
	rot_vel = lerpf(rot_vel, rot_target, 1.0 -exp(-delta * 2))
	if rot_target == 0.0:
		shake.intensity = lerpf(shake.intensity, 0.0, 1.0 - exp(-delta * 2))
	else:shake.intensity = lerpf(shake.intensity, 1.0, 1.0 - exp(-delta * 2))
	rotate(rot_vel * delta)
	for kite in kites:
		if not kite: continue 
		if not kite.target and p:
			if not targets.is_empty():
				kite.target = targets.filter(func(x): return is_instance_valid(x)).pick_random()
				kite.tween_color(Color.CRIMSON, 1.0)
		if kite.target:
			kite.go = true
func on_timeout() -> void:
	if kites.size() < kite_count:
		var k: Kite = k_sc.instantiate()
		k.erased.connect(on_kite_erasure)
		var dist = randf_range(dist_low, dist_high)
		var angle = randf_range(-PI, PI)
		k.position = global_position + Vector2(cos(angle) * dist, sin(angle) * dist)
		k.rotation = randf_range(-PI, PI)
		Global.game.add_world_child(k)
		kites.push_back(k)

func on_kite_erasure(k: Kite) -> void:
	var ghost := Ghost.new()
	ghost.modulate.a = 0.5
	ghost.texture = k.sprite.texture
	ghost.transform = k.global_transform
	Global.game.add_world_child(ghost)
	kites.erase(k)
	k.queue_free()
func hit(who: Entity, shape: Node2D, h_v: Vector2) -> void:
	health -= who.damage

func on_enter(a: Area2D) -> void:
	if a is DetectArea and not a.target in targets:
		targets.push_back(a.target)
	
func on_exit(a: Area2D) -> void:
	if a is DetectArea and a.target in targets:
		targets.erase(a.target)

func set_health(new: float) -> void:
	health = new
	if health < 0 and active:
		print("DEATH")
		for m in kites:
			m.on_own = true
			on_kite_erasure(m)
		var ghost := Ghost.new()
		ghost.modulate.a = 0.5
		ghost.texture = sprite.texture
		ghost.transform = sprite.global_transform
		Global.game.add_world_child(ghost)
		queue_free()
		active = false

func kill_all_kites() -> void:
	for kite in kites:
		on_kite_erasure(kite)
