extends KinematicBody

signal player_died
signal player_hit(damage)
signal enemy_kicked(enemy)
signal update_player_health(health)

onready var camera = self.get_node("Camera")
onready var jump_timer = self.get_node("Timer")
onready var animator = self.get_node("AnimationPlayer")

var health = 10
var can_jump = false

var move_speed = 30.0
var jump_speed = 30.0

var player_rotation = 0.0
var rotation_amount = 2.0

var moon_origin = Vector3(0.0, 0.0, 0.0)

var velocity = Vector3(0.0, 0.0, 0.0)
var gravity_point = Vector3(0.0, 0.0, 0.0)
var gravity = 10.0

func _ready():
	self.add_to_group("player")
	
	self.connect("player_hit", self, "_on_player_hit")
	
	# ensure the camera is looking at the player
	camera.global_transform.basis.z = -camera.global_transform.origin.direction_to(self.global_transform.origin)

func _process(delta):
	velocity = Vector3(0.0, 0.0, 0.0)
	player_rotation = 0.0
	
	# walking
	if (Input.is_action_pressed("player_move_forward")):
		velocity += -self.transform.basis.z * move_speed
		
		if (can_jump):
			animator.play("Walk")
	if (Input.is_action_pressed("player_move_backward")):
		velocity += self.transform.basis.z * move_speed
		
		if (can_jump):
			animator.play("Walk")
	
	# reset walking animation
	if (Input.is_action_just_released("player_move_forward") || Input.is_action_just_released("player_move_backward")):
		if (animator.current_animation == "Walk"):
			animator.stop(true)
			animator.seek(0, true)
	
	# jumping
	if (Input.is_action_pressed("player_move_jump")):
		var time_left = jump_timer.get_time_left()
		var wait_time = jump_timer.get_wait_time()
		if (jump_timer.is_stopped() && can_jump):
			animator.play("Jump", -1, 2.0)
			jump_timer.start()
			can_jump = false
		elif (!jump_timer.is_stopped()):
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
	
	# apply gravity
	velocity += self.transform.origin.direction_to(gravity_point) * gravity
	
	# rotate
	self.rotate(self.transform.basis.y, player_rotation * delta)
	
	# finally, move the player
	var collision = self.move_and_collide(velocity * delta)
	
	# lastly, check collisions
	if (collision != null && collision.collider != null):
		var collider = collision.collider
		
		for group in collider.get_groups():
			match group:
				"enemy":
					self.emit_signal("enemy_kicked", collider)
				"moon":
					jump_timer.stop()
					can_jump = true
				"projectile":
					#collider.set_physics_process(false)
					collider.emit_signal("impact", collider, self)
				_:
					continue

func _on_player_hit(damage):
	health -= damage
	self.emit_signal("update_player_health", health)
	
	if (health <= 0):
		self.set_process(false)
		self.set_physics_process(false)
		animator.play("Die")
		
		self.emit_signal("player_died")
