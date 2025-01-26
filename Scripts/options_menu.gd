extends VBoxContainer

@export var _master_volume_slider: Slider = null
@export var _bgm_volume_slider: Slider = null
@export var _effects_volume_slider: Slider = null

@onready var _master_bus := AudioServer.get_bus_index("Master")
@onready var _bgm_bus := AudioServer.get_bus_index("BGM")
@onready var _effects_bus := AudioServer.get_bus_index("Effects")

func _ready() -> void:
	_master_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_master_bus))
	_bgm_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_bgm_bus))
	_effects_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_effects_bus))
	
	_master_volume_slider.connect("value_changed", _value_changed_handler(_master_bus))
	_bgm_volume_slider.connect("value_changed", _value_changed_handler(_bgm_bus))
	_effects_volume_slider.connect("value_changed", _value_changed_handler(_effects_bus))

func _value_changed_handler(bus):
	return func(value): AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _on_visibility_changed() -> void:
	if self.visible:
		_master_volume_slider.grab_focus()
