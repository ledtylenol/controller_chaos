extends Entity
class_name Pentagon

@export var hit_poly: CollisionPolygon2D
@export var hurt_poly: CollisionPolygon2D
const TRIANGLE = preload("res://entities/triangle/triangle.tscn")
var hp := 3
@onready var label: Label = $Label

func _physics_process(delta: float) -> void:
	label.global_position = global_position
	label.text = "%s" % hp
	velocity *= 0.9
	var col = move_and_collide(velocity * delta)
	if col and col.get_collider() is Triangle and col.get_local_shape() == hit_poly:
		col.get_collider().hit(self, col.get_local_shape(), velocity)
func hit(who: Entity, shape: Node2D, hit_vel :Vector2):
	if shape == hit_poly:
		print("GET HIT IDIOT")
		who.hit(self, hit_poly, velocity)
	elif shape == hurt_poly:
		velocity += hit_vel
		print(hp)
		hp -= 1
		if hp <= 0:
			collision_layer = 0
			collision_mask = 0
			var rot := -PI/4
			for i in 2:
				var t = TRIANGLE.instantiate()
				t.transform = global_transform
				t.velocity = velocity.rotated(rot) 
				Global.game.add_world_child(t)
				prints(rot, t)
				rot += PI
			queue_free()
	else: print("iunno")
