extends Node

var rng = RandomNumberGenerator.new()
@export var flip = 0
@onready var _animated_sprite = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_number = rng.randf_range(0, 5.0)
	$Timer.start(random_number)
	$AnimatedSprite2D.flip_h= flip

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	_animated_sprite.play("Default")
