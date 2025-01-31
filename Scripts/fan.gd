extends Area2D

@export var fan_speed: float = -100
@export var dampening: float = 200

var bubbles: Array[Bubble] = []

@onready var area_half_size_x = get_global_transform().get_scale().x * $CollisionShape2D.shape.get_rect().size.x / 2
@onready var area_size_y = get_global_transform().get_scale().y * $CollisionShape2D.shape.get_rect().size.y

@onready var up = get_global_transform().y.normalized()
@onready var forward = get_global_transform().x.normalized()
@onready var center_point = get_global_transform().origin + up * (area_size_y / 2)

func _ready() -> void:
	$GPUParticles2D.lifetime = sqrt(2 * area_size_y / 98)
	var particle_gravity = -up * 98
	($GPUParticles2D.process_material as ParticleProcessMaterial).gravity = Vector3(particle_gravity.x, particle_gravity.y, 0.0)

func _physics_process(delta: float) -> void:
	for bubble_idx in range(bubbles.size() - 1, -1, -1):
		var bubble = bubbles[bubble_idx]
		
		if not is_instance_valid(bubble) or bubble.is_queued_for_deletion():
			bubbles.remove_at(bubble_idx)
		
		var bubble_pos = bubble.get_global_transform().origin
		var diff = center_point - bubble_pos
		var towards_distance: float = (diff - diff.dot(up) * up).length()
		
		var towards_percent = towards_distance / area_half_size_x
		var dot = bubble.linear_velocity.dot(forward)
		
		var skew: float
		if abs(dot) > 100:
			# Rapid slow down when bubble is fast
			skew = -dot * 20
		elif towards_percent > 0.2:
			# Moderate slow down when bubble has slowed down
			var deaccleration = ease(towards_percent, 0.2)
			skew = -sign(dot) * deaccleration * dampening
		else:
			# Sway from side to side when in center column
			skew = sign(dot) * 2 * dampening
		
		var towards_force = forward * skew
		
		var up_distance: float = (diff - diff.dot(forward) * forward).length()
		var up_percent = up_distance / area_size_y
		
		var up_skew: float
		if up_percent > 0.9:
			var up_dot = bubble.linear_velocity.dot(up)
			up_skew = -sign(up_dot) * -ease(up_percent, 0.2)
		else:
			up_skew = ease(1 - up_percent, 0.2)
		
		var up_force = fan_speed * up * up_skew
		bubble.linear_velocity += (towards_force + up_force) * delta

func _on_body_entered(body: Node2D) -> void:
	if body is Bubble:
		body.linear_velocity += up * fan_speed
		bubbles.push_back(body)
		body.stop_lifetime()


func _on_body_exited(body: Node2D) -> void:
	if body is Bubble:
		bubbles.erase(body)
		var dot = body.linear_velocity.dot(up)
		body.linear_velocity += up * -dot * 0.9
		body.start_lifetime()
