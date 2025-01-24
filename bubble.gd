extends RigidBody2D

func pop() -> void:
	self.queue_free()

func _on_timer_timeout() -> void:
	pop()

func _on_body_entered(body: Node) -> void:
	pop()
