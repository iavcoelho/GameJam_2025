extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.stream = preload("res://Audio/death.wav")
	self.bus = "Effects"
