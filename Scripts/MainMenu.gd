extends Control

@export var start_button: Control = null
@export var first_level: PackedScene = preload("res://Levels/Tutorial/stage1.tscn")

@export var main_menu: Control = null
@export var level_select_menu: Control = null
@export var options_menu: Control = null

func _ready():
	start_button.grab_focus()

func play_pressed() -> void:
	get_tree().change_scene_to_packed(first_level)

func level_select_pressed() -> void:
	main_menu.visible = false
	level_select_menu.visible = true

func options_pressed() -> void:
	main_menu.visible = false
	options_menu.visible = true

func quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	main_menu.visible = true
	options_menu.visible = false
	level_select_menu.visible = false
	start_button.grab_focus()
