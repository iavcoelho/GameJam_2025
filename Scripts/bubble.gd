extends RigidBody2D

class_name Bubble

@onready var _animated_sprite = $AnimatedSprite2D

var dying: bool = false

func pop() -> void:
	if dying:
		return
	
	dying = true
	
	_animated_sprite.connect("animation_finished", self.queue_free)
	self.set_deferred("freeze", true)
	self.collision_layer = 2
	self.collision_mask = 2
	_animated_sprite.play("pop")

func _on_timer_timeout() -> void:
	pop()

func _on_body_entered(body: Node) -> void:
	pop()
