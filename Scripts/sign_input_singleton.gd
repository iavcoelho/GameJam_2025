extends Node

var using_gamepad = true

signal input_changed

func _input(event) -> void:
	if using_gamepad:
		if event is InputEventMouseButton or event is InputEventKey:
			using_gamepad = false
			input_changed.emit()
	else:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			using_gamepad = true
			input_changed.emit()

func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	using_gamepad = connected
	input_changed.emit()
