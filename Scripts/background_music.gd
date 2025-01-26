extends AudioStreamPlayer

var ost = preload("res://Audio/OST_Shadowcave.ogg")

func _ready() -> void:
	self.stream = ost
	self.bus = "BGM"
	self.play()
