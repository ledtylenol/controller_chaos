extends Camera2D
class_name PlayerCamera

var z := 0.3:
	set(v):
		z = clampf(v, 0.1, 0.3)
func _process(delta: float) -> void:
	zoom = lerp(zoom, Vector2(z, z), 1.0 - exp(-delta * 5))

func _input(event: InputEvent) -> void:
	var v =  Input.get_axis("zoom_out", "zoom_in") 
	if v > 0:
		z *= 1.1
	elif v < 0:
		z *= 0.9  
