extends CharacterBody2D

class_name Player

@export var speed: float = 300
@export var jump_velocity: float = -400
@export var kill_plane: float = 500

@export var short_jump_time: float = 0.1
@export var max_jump_time: float = 0.2

@export var shoot_speed: float = 100
@export var shoot_offset: float = 64

@export var Bullet = preload("res://bubble.tscn")

@export var attack_sfx: Array[AudioStream] = []

var shoot_parent: Node
var direction_inherit: float = 1
var can_fire: bool = false

var is_jumping: bool = false
var jump_held: bool = false
var jump_time: float = 0.0

var dying: bool = false

var prev_on_floor: bool = true

var _gravity_coeff: float = 1.0

enum AnimationStates {
  JUMPING,
  LANDING,
  WIND_UP,
  ATTACKING,
  NORMAL,
  DYING
}

var animation_state: AnimationStates = AnimationStates.NORMAL

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _attack_audio_player: AudioStreamPlayer2D = $AttackSfx
@onready var _jump_audio_player: AudioStreamPlayer2D = $JumpSfx
@onready var _landing_audio_player: AudioStreamPlayer2D = $LandingSfx
@onready var _water_enter_audio_player: AudioStreamPlayer2D = $WaterEnterSfx

@onready var _water_splash_particles: GPUParticles2D = $WaterSplashParticles

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


func _input(event: InputEvent):
	if event.is_action_pressed("reset"):
		die()
		return
		
	if self.dying:
		return

	# Needs to go through Input because triggers generate multiple events
	if Input.is_action_just_pressed("shoot") and self.can_fire:
		self.can_fire = false
		self.animation_state = AnimationStates.WIND_UP
		_animated_sprite.play("wind_up")
		
		_attack_audio_player.stop()
		_attack_audio_player.stream = self.attack_sfx.pick_random()
		_attack_audio_player.play()
		
		return

func die():
	self.dying = true
	self.animation_state = AnimationStates.DYING
	self.velocity.x = 0.0
	_animated_sprite.play("die")
	DeathSfx.play()

func finish_death():
	get_tree().reload_current_scene()

func _process(_delta: float) -> void:
	if position.y > kill_plane:
		finish_death()
		
	match self.animation_state:
		AnimationStates.JUMPING:
			_animated_sprite.play("jump")
		AnimationStates.LANDING:
			_animated_sprite.play("landing")
		AnimationStates.WIND_UP:
			pass
		AnimationStates.ATTACKING:
			pass
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
		AnimationStates.DYING:
			pass


func start_jump() -> void:
	velocity.y = jump_velocity
	self.is_jumping = true
	self.jump_held = true
	self.jump_time = 0.0

	self.animation_state = AnimationStates.JUMPING
	self._jump_audio_player.play()


func _on_animated_sprite_2d_animation_finished() -> void:
	if self.animation_state == AnimationStates.WIND_UP:
		shoot()
		self.animation_state = AnimationStates.ATTACKING
		_animated_sprite.play("attack")
	elif self.animation_state == AnimationStates.DYING:
		finish_death()
	else:
		self.animation_state = AnimationStates.NORMAL


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += self._gravity_coeff * get_gravity() * delta
	elif not self.dying:
		self.is_jumping = false
		
		if self.animation_state != AnimationStates.WIND_UP:
			self.can_fire = true
		
		if not self.prev_on_floor:
			self.animation_state = AnimationStates.LANDING
			_landing_audio_player.play()

	if not self.dying:
		self.prev_on_floor = is_on_floor()

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
	
	if self.dying:
		return
	
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
		elif body is Bubble:
			body.pop()
			
			if collision.get_angle() < PI/2:
				velocity.y = jump_velocity
				self.is_jumping = false

var _water_enters: int = 0

@onready var _master_bus := AudioServer.get_bus_index("Master")

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		var tile_coords = body.get_coords_for_body_rid(body_rid)
		var tile = body.get_cell_tile_data(tile_coords)
		if tile.get_custom_data("save_bubble"):
			if _water_enters == 0:
				for i in AudioServer.get_bus_effect_count(_master_bus):
					AudioServer.set_bus_effect_enabled(_master_bus, i, true)
				
				if velocity.y > 0:
					var sound = min(velocity.y / 500, 1.0)
					_water_enter_audio_player.volume_db = linear_to_db(ease(sound, 3.6) + 0.1)
					_water_enter_audio_player.play()
				
				var tile_y = body.to_global(body.map_to_local(tile_coords)).y
				tile_y -= body.tile_set.tile_size.y / 2
				
				var splash_coords = Vector2(global_position.x, tile_y)
				_water_splash_particles.global_position = splash_coords
				_water_splash_particles.emitting = true
				
				_gravity_coeff = 0.1
				velocity.y = min(velocity.y, 200)
				
			_water_enters += 1


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		var tile_coords = body.get_coords_for_body_rid(body_rid)
		var tile = body.get_cell_tile_data(tile_coords)
		if tile.get_custom_data("save_bubble"):
			_water_enters -= 1
			
			if _water_enters == 0:
				for i in AudioServer.get_bus_effect_count(_master_bus):
					AudioServer.set_bus_effect_enabled(_master_bus, i, false)
					
				_gravity_coeff = 1.0
