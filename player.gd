extends CharacterBody2D

@export var speed: float = 300
@export var jump_velocity: float = -400
@export var kill_plane: float = 50

@export var Bullet = preload("res://bubble.tscn")

var shoot_parent: Node
var can_fire: bool = false

func _ready() -> void:
	self.shoot_parent = get_parent()
	if self.shoot_parent == null:
		self.shoot_parent = self
	

func _input(event):
	if event.is_action_pressed("shoot") and can_fire:
		can_fire = false
		var bullet_instance = Bullet.instantiate()
		self.shoot_parent.add_child(bullet_instance)


func _process(delta: float) -> void:
	if position.y > kill_plane:
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_fire = true

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
