extends RigidBody2D

class_name Bubble

func pop() -> void:
	self.queue_free()

func _on_timer_timeout() -> void:
	pop()

func _on_body_entered(body: Node) -> void:
	pop()
