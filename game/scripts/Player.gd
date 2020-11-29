extends KinematicBody

signal player_died
signal player_hit(health) # `health` is the new health value, not the damage done
signal enemy_kicked(enemy)

onready var camera = self.get_node("Camera")
onready var jump_timer = self.get_node("Timer")
onready var animator = self.get_node("AnimationPlayer")

var health = 10

var move_speed = 25.0
var jump_speed = 5.0

var player_rotation = 0.0
var rotation_amount = 1.0

var is_jumping = false
var moon_origin = Vector3(0.0, 0.0, 0.0)

var velocity = Vector3(0.0, 0.0, 0.0)
var gravity_point = Vector3(0.0, 0.0, 0.0)
var gravity = 10.0

func _ready():
	self.add_to_group("player")
	
	# ensure the camera is looking at the player
	camera.global_transform.basis.z = -camera.global_transform.origin.direction_to(self.global_transform.origin)

func _process(delta):
	velocity = Vector3(0.0, 0.0, 0.0)
	player_rotation = 0.0
	
	# walking
	if (Input.is_action_pressed("player_move_forward")):
		velocity += -self.transform.basis.z * move_speed
		animator.play("Walk")
	if (Input.is_action_pressed("player_move_backward")):
		velocity += self.transform.basis.z * move_speed
		animator.play("Walk")
	
	# reset walking animation
	if (Input.is_action_just_released("player_move_forward") || Input.is_action_just_released("player_move_backward")):
		animator.stop(true)
		animator.seek(0, true)
	
	# jumping
	if (Input.is_action_pressed("player_move_jump")):
		var time_left = jump_timer.get_time_left()
		var wait_time = jump_timer.get_wait_time()
		var gravity = self.transform.origin.direction_to(gravity_point) * 10.0
		if (jump_timer.is_stopped() && !is_jumping):
			jump_timer.start()
			animator.play("Jump")
			is_jumping = true
		elif (time_left > 0.0 && is_jumping):
			velocity += self.transform.basis.y * jump_speed
	
	# turning
	if (Input.is_action_pressed("player_move_left")):
		player_rotation += rotation_amount
	if (Input.is_action_pressed("player_move_right")):
		player_rotation += -rotation_amount

func _physics_process(delta):
	
	# orient the player
	var direction = self.transform.origin.direction_to(gravity_point)
	var player_down = -self.transform.basis.y
	var axis = player_down.cross(direction)
	var phi = player_down.angle_to(direction)
	if (axis.length_squared() == 0):
		axis = -self.transform.basis.z
	else:
		axis = axis.normalized()
		self.transform.basis = self.transform.basis.rotated(axis, phi)
		self.transform = self.transform.orthonormalized()
	
	# apply gravity and enable/disable jumping
	velocity += self.transform.origin.direction_to(gravity_point) * gravity
	
	# rotate
	self.rotate(self.transform.basis.y, player_rotation * delta)
	
	# finally, move the player
	var collision = self.move_and_collide(velocity * delta)
	
	# lastly, check collisions
	if (collision != null && collision.collider != null):
		var collider = collision.collider
		var groups = collider.get_groups()
		
		for group in collider.get_groups():
			match group:
				"enemy":
					self.emit_signal("enemy_kicked", collider)
				"moon":
					is_jumping = false
					
					if (animator.current_animation == "Jump"):
						animator.stop(true)
						animator.seek(0)
				"projectile":
					var damage = collider.get_damage()
					health -= damage
					
					self.emit_signal("player_hit", health)
					
					if (health <= 0):
						self.set_process(false)
						self.set_physics_process(false)
						animator.play("Die")
						
						self.emit_signal("player_died")
				_:
					continue
