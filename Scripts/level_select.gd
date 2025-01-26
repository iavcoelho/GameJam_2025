extends VBoxContainer

@export var level_button: PackedScene
@export var levels: Array[Level] = []

@onready var _last_button: Control = $Back

func _ready() -> void:
	levels.reverse()
	for level in levels:
		var button = level_button.instantiate() as Button
		button.text = level.name
		button.connect("pressed", func(): _load_level(level.scene))
		add_child(button)
		move_child(button, 0)
		
		button.focus_neighbor_bottom = _last_button.get_path()
		_last_button.focus_neighbor_top = button.get_path()
		
		_last_button = button

func _load_level(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)

func _on_visibility_changed() -> void:
	if self.visible:
		_last_button.grab_focus()
