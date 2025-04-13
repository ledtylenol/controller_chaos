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
