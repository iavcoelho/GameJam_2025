extends Area2D

@export_file("*.tscn") var next_scene: String
@export_file("*.tscn") var main_menu: String

@onready var _menu: CanvasLayer = $Menu
@onready var _next_btn: Control = $Menu/Controls/Next

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_menu.show()
		_next_btn.grab_focus()
		get_tree().paused = true
		
func _next() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(next_scene)

func _back() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu)
