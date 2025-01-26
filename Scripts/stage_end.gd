extends Area2D

@export_file("*.tscn") var next_scene: String

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		call_deferred("_switch_level")
		
func _switch_level():
	get_tree().change_scene_to_file(next_scene)
