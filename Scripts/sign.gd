extends Node
class_name Sign

@onready var _animated_sprite = $Area2D/AnimatedSprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: 
		_animated_sprite.connect("animation_finished", self.queue_free)
		_animated_sprite.play("Arrow")
	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D: 
		_animated_sprite.play("Idle")
