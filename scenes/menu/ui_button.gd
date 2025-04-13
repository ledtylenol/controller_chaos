@tool
extends Control

@export var tex_normal :Texture = null
@export var tex_hover :Texture = null

signal pressed

func _ready() -> void:
	$TextureButton.texture_normal = tex_normal
	$TextureButton.texture_hover = tex_hover


func _on_texture_button_pressed() -> void:
	pressed.emit()
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.9,0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(1,1), 0.1).set_trans(Tween.TRANS_BOUNCE)
#func _on_texture_button_focus_entered() -> void:
	


func _on_texture_button_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1,1.1), 0.1)


func _on_texture_button_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.1)
