extends CharacterBody2D

@export var speed: float = 300
@export var jump_velocity: float = -400
@export var kill_plane: float = 500

@export var short_jump_time: float = 0.1
@export var max_jump_time: float = 0.2

@export var shoot_speed: float = 100
@export var shoot_offset: float = 64

@export var Bullet = preload("res://bubble.tscn")

var shoot_parent: Node
var direction_inherit: float = 1
var can_fire: bool = false

var is_jumping: bool = false
var jump_held: bool = false
var jump_time: float = 0.0

var prev_on_floor: bool = true

enum AnimationStates {
  JUMPING,
  LANDING,
  WIND_UP,
  ATTACKING,
  NORMAL,
}

var animation_state: AnimationStates = AnimationStates.NORMAL

@onready var _animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	self.shoot_parent = get_parent()
	if self.shoot_parent == null:
		self.shoot_parent = self


func shoot() -> void:		
	var bullet_instance: Bubble = Bullet.instantiate()
	self.shoot_parent.add_child(bullet_instance)
	bullet_instance.global_position.x = position.x + direction_inherit * shoot_offset
	bullet_instance.global_position.y = position.y
	bullet_instance.linear_velocity.x = direction_inherit * shoot_speed


func _input(event):
	if event is not InputEvent:
		return

	if Input.is_action_just_pressed("shoot") and can_fire:
		can_fire = false
		self.animation_state = AnimationStates.WIND_UP

func die():
	get_tree().reload_current_scene()

func _process(_delta: float) -> void:
	if position.y > kill_plane:
		die()
		
	match self.animation_state:
		AnimationStates.JUMPING:
			_animated_sprite.play("jump")
		AnimationStates.LANDING:
			_animated_sprite.play("landing")
		AnimationStates.WIND_UP:
			_animated_sprite.play("wind_up")
		AnimationStates.ATTACKING:
			_animated_sprite.play("attack")
		AnimationStates.NORMAL:
			if not is_on_floor():
				if velocity.y < 0.0:
					_animated_sprite.play("up")
				else:
					_animated_sprite.play("down")
			elif abs(velocity.x) > 0.0:
				_animated_sprite.play("running")
			else:
				_animated_sprite.play("idle")


func start_jump() -> void:
	velocity.y = jump_velocity
	self.is_jumping = true
	self.jump_held = true
	self.jump_time = 0.0

	self.animation_state = AnimationStates.JUMPING


func _on_animated_sprite_2d_animation_finished() -> void:
	if self.animation_state == AnimationStates.WIND_UP:
		shoot()
		self.animation_state = AnimationStates.ATTACKING
	else:
		self.animation_state = AnimationStates.NORMAL


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		self.is_jumping = false
		
		if self.animation_state != AnimationStates.WIND_UP:
			self.can_fire = true
		
		if not self.prev_on_floor:
			self.animation_state = AnimationStates.LANDING
	
	self.prev_on_floor = is_on_floor()
	
	if Input.is_action_just_pressed("reset"):
		die()
		return

	# Handle jump.
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			start_jump()
	elif self.is_jumping:
		self.jump_time += delta
		
		if Input.is_action_just_released("jump"):
			jump_held = false
		
		if jump_held and self.jump_time > short_jump_time and self.jump_time < max_jump_time:
			velocity.y = jump_velocity
		
		if not jump_held and self.jump_time > short_jump_time:
			velocity.y = max(velocity.y, 0.0)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		_animated_sprite.flip_h = direction < 0
		direction_inherit = 1 if direction >= 0.0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var body = collision.get_collider()
		
		if body is TileMapLayer:
			var tile_rid = collision.get_collider_rid()
			if tile_rid == null:
				continue
			var tile_coords = body.get_coords_for_body_rid(tile_rid)
			var tile = body.get_cell_tile_data(tile_coords)
			if tile.get_custom_data("die"):
				die()
				return
			
		
		if body is Bubble:
			body.pop()
			
			if collision.get_angle() < PI/2:
				velocity.y = jump_velocity
				self.is_jumping = false
