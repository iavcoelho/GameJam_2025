extends Node
class_name Sign

var interactable: bool = false
@onready var _animated_sprite = $Area2D/AnimatedSprite2D

@export var sign_content = []
@onready var content_length = len(sign_content)
@onready var sign_progress = content_length

var initial_input = "Press '{input}'"
var progress_sign_text = "'{input}' to keep reading"
@onready var sign_label = $Content
@onready var interact_label = $Interact
var content_tween: Tween
var interact_tween: Tween
var using_gamepad = false
var first_interaction = true
	
func format_text(input: String):
	var text = initial_input if first_interaction else progress_sign_text

	return text.format({"input": input})

func _ready() -> void:
	sign_label.text = ""
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		_animated_sprite.play("Arrow")
		interactable = true
	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player: 
		_animated_sprite.play("Idle")
		interactable = false
	

func _input(event) -> void:
	if using_gamepad:
		if event is InputEventMouseButton or event is InputEventKey:
			using_gamepad = false
			_update_label(interact_label, format_text, "read_sign")
			_update_label(sign_label, func(input): return (sign_content[sign_progress] if sign_progress != content_length else "").format({"input": input}), "shoot")
	else:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			using_gamepad = true
			_update_label(interact_label, format_text, "read_sign")
			_update_label(sign_label,func(input): return (sign_content[sign_progress] if sign_progress != content_length else "").format({"input": input}), "shoot")
	if interactable and event.is_action_pressed("read_sign"):
		if content_tween != null and content_tween.is_running():
			content_tween.custom_step(2)
			return
		sign_progress = (sign_progress + 1) % (content_length + 1)
		content_tween = create_tween()
		
		var fade_out: PropertyTweener
		
		if sign_progress == content_length:
			first_interaction = true
			interact_tween = create_tween()
			fade_out = interact_tween.tween_property(interact_label, "modulate:a", 0.0, 0.3)
			interact_tween.tween_property(interact_label, "modulate:a", 1.0, 0.3)
			fade_out.connect("finished", func(): _update_label(interact_label, format_text, "read_sign"))
			
			fade_out = content_tween.tween_property(sign_label, "modulate:a", 0.0, 1.0)
			content_tween.tween_property(sign_label, "modulate:a", 1.0, 1.0)
			fade_out.connect("finished", func(): _update_label(sign_label, func(input): return "", "shoot"))
			return
			
		
		if sign_progress == 0:
			first_interaction = false
			interact_tween = create_tween()
			fade_out = interact_tween.tween_property(interact_label, "modulate:a", 0.0, 0.3)
			interact_tween.tween_property(interact_label, "modulate:a", 1.0, 0.3)
			fade_out.connect("finished", func(): _update_label(interact_label, format_text, "read_sign"))
			
			content_tween.tween_property(sign_label, "modulate:a", 0.0, 0.0)
			_update_label(sign_label, func(input): return sign_content[sign_progress].format({"input": input}), "shoot")
			sign_label.text = sign_content[sign_progress]
			content_tween.tween_property(sign_label, "modulate:a", 1.0, 1.0)
			return
			
		fade_out = content_tween.tween_property(sign_label, "modulate:a", 0.0, 1.0)
		content_tween.tween_property(sign_label, "modulate:a", 1.0, 1.0)
		fade_out.connect("finished", func(): _update_label(sign_label, func(input): return sign_content[sign_progress].format({"input": input}), "shoot"))

func _update_label(label: Label, format: Callable, action: String) -> void:
	for event in InputMap.action_get_events(action):
		if using_gamepad:
			if event is InputEventJoypadButton:
				var button = "None"
				match event.button_index:
					JOY_BUTTON_A:
						button = "A"
					JOY_BUTTON_B:
						button = "B"
					JOY_BUTTON_X:
						button = "X"
					JOY_BUTTON_Y:
						button = "Y"
				label.text = format.call(button)
				break

			if event is InputEventJoypadMotion:
				var axis = "None"
				match event.axis:
					JOY_AXIS_TRIGGER_LEFT:
						axis = "LT"
					JOY_AXIS_TRIGGER_RIGHT:
						axis = "RT"
				label.text = format.call(axis)
				break

		elif event is InputEventKey:
			var key = event.keycode
			if key == KEY_NONE:
				key = DisplayServer.keyboard_get_label_from_physical(event.physical_keycode)
			label.text = format.call(OS.get_keycode_string(key))
			break


func _on_joy_connection_changed(_device:int, connected:bool) -> void:
	using_gamepad = connected
	_update_label(interact_label, format_text, "read_sign")
