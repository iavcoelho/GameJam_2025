extends AudioStreamPlayer2D

var ost = preload("res://Audio/OST_Shadowcave.ogg")

func _ready() -> void:
	self.stream = ost
	self.volume_db = 24
	self.play()
