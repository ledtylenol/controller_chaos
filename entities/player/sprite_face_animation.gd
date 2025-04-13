extends Node

var eye_timer :float = 0.0
var current_eye_state :int = 0

func set_eye_state_to( state_number:int ) -> void:
	current_eye_state = state_number
	eye_timer = 0.1

func _process(delta: float) -> void:
	eye_timer -= delta
	
	match(current_eye_state):
		# Angy
		0:
			$"../Face".frame = 0
		# Open
		1:
			$"../Face".frame = 1
			if eye_timer < 0:
				current_eye_state = 0
		# Closed
		2:
			$"../Face".frame = 2
			if eye_timer < 0:
				current_eye_state = 1
				eye_timer = 0.5
		# Dead
		3:
			$"../Face".frame = 3
