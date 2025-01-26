extends CanvasLayer

@export_file("*.tscn") var main_menu: String

@export var first_button: Control

signal reset

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self.visible = !self.visible
		if visible:
			get_tree().paused = true
			first_button.grab_focus()
		else:
			get_tree().paused = false


func _on_resume_pressed() -> void:
	self.visible = false
	get_tree().paused = false


func _on_reset_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	reset.emit()


func _on_back_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu)
