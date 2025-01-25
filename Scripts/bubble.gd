extends RigidBody2D

class_name Bubble

@onready var _animated_sprite = $AnimatedSprite2D

var dying: bool = false

func pop() -> void:
	if dying:
		return
	
	dying = true
	
	_animated_sprite.connect("animation_finished", self.queue_free)
	self.set_deferred("freeze", true)
	self.collision_layer = 2
	self.collision_mask = 2
	_animated_sprite.play("pop")

func _on_timer_timeout() -> void:
	pop()

	
var is_in_water:bool = false
func collision(body_rid: RID, body: Node):
	if body is TileMapLayer:
		var tile_coords = body.get_coords_for_body_rid(body_rid)
		var tile = body.get_cell_tile_data(tile_coords)
		if tile.get_custom_data("save_bubble"):
			self.linear_velocity.x *= 0.8
			self.linear_velocity.y = -15
			is_in_water = true
			return
	pop()

func _on_body_shape_entered(body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	collision(body_rid, body)

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	collision(body_rid, body)


func _on_body_exited(_body: Node) -> void:
	is_in_water = false
	
func _on_area_2d_body_exited(_body: Node2D) -> void:
	is_in_water = false	

func _process(_delta: float) -> void:
	if is_in_water:
		$Timer.paused = true
		self.linear_velocity.y = -25
	else:
		$Timer.start()
