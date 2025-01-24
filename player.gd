extends CharacterBody2D

@export var speed: float = 300
@export var jump_velocity: float = -400
@export var kill_plane: float = 50

@export var short_jump_time: float = 0.1
@export var max_jump_time: float = 0.2

@export var shoot_speed: float = 100
@export var shoot_offset: float = 64

@export var Bullet = preload("res://bubble.tscn")

var shoot_parent: Node
var direction_inherit: float = 1
var can_fire: bool = false
var jump_held: bool = false
var jump_time: float = 0.0

@onready var _animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	self.shoot_parent = get_parent()
	if self.shoot_parent == null:
		self.shoot_parent = self
	

func _input(event):
	if event.is_action_pressed("shoot") and can_fire:
		can_fire = false
		var bullet_instance: RigidBody2D = Bullet.instantiate()
		self.shoot_parent.add_child(bullet_instance)
		bullet_instance.global_position.x = position.x + direction_inherit * shoot_offset
		bullet_instance.global_position.y = position.y
		bullet_instance.linear_velocity.x = direction_inherit * shoot_speed


func _process(delta: float) -> void:
	if position.y > kill_plane:
		get_tree().reload_current_scene()
	
	if velocity.length() < 0.1:
		_animated_sprite.play("idle")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_fire = true

	# Handle jump.
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			self.jump_held = true
			self.jump_time = 0.0
	else:
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
		
		if body is Bubble and collision.get_angle() < PI/4:
			velocity.y = jump_velocity
			jump_held = true
