extends Control

@export var start_button: Control = null
@export var first_level: PackedScene = preload("res://Levels/Tutorial/stage1.tscn")

func _ready():
	start_button.grab_focus()

func play_pressed() -> void:
	get_tree().change_scene_to_packed(first_level)

func options_pressed() -> void:
	pass # Replace with function body.

func quit_pressed() -> void:
	get_tree().quit()
