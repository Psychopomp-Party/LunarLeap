extends KinematicBody

signal player_died

onready var gravity_area = self.get_parent().get_node("GravityModifier")
onready var camera = self.get_node("Camera")
onready var moon = self.get_parent().get_node("Moon")
onready var jump_timer = self.get_node("Timer")
onready var animator = self.get_node("AnimationPlayer")
onready var parent = self.get_parent()

var health = 10

var move_speed = 25.0
var movement = Vector3(0.0, 0.0, 0.0)

var rotation_speed = 2.0
var player_rotation = 0.0

var is_jumping = false

func _ready():
	self.add_to_group("player")
	#animator.connect("animation_finished", self, "_on_animation_finished")
	camera.global_transform.basis.z = -camera.global_transform.origin.direction_to(self.global_transform.origin)

func _process(delta):
	movement = Vector3(0.0, 0.0, 0.0)
	player_rotation = 0.0
	
	# walking
	if (Input.is_action_pressed("player_move_forward")):
		movement += -self.transform.basis.z * move_speed
	if (Input.is_action_pressed("player_move_backward")):
		movement += self.transform.basis.z * move_speed
	if (Input.is_action_just_released("player_move_forward") || Input.is_action_just_released("player_move_backward")):
		animator.stop(true)
		animator.seek(0, true)
	
	# indicate if walking animation should play
	if (!is_jumping && movement != Vector3(0.0, 0.0, 0.0)):
		animator.play("Walk")
	
	# jumping
	if (Input.is_action_pressed("player_move_jump")):
		var time_left = jump_timer.get_time_left()
		var wait_time = jump_timer.get_wait_time()
		if (jump_timer.is_stopped() && !is_jumping):
			jump_timer.start()
			is_jumping = true
			animator.play("Jump")
		elif (time_left > 0.0 && is_jumping):
			movement += self.transform.basis.y * gravity_area.gravity * 16.0
	
	# turning
	if (Input.is_action_pressed("player_move_left")):
		player_rotation += rotation_speed
	if (Input.is_action_pressed("player_move_right")):
		player_rotation += -rotation_speed

func _physics_process(delta):
	
	# orient the player on the moon
	var moon_direction = self.transform.origin.direction_to(moon.transform.origin)
	var player_down = -self.transform.basis.y
	var axis = player_down.cross(moon_direction)
	var phi = player_down.angle_to(moon_direction)
	if (axis.length_squared() == 0):
		axis = -self.transform.basis.z
	else:
		axis = axis.normalized()
		self.transform.basis = self.transform.basis.rotated(axis, phi)
		self.transform = self.transform.orthonormalized()
	
	# apply gravity and enable/disable jumping
	var velocity = movement
	if (is_jumping && self.is_on_floor()):
		jump_timer.stop()
		is_jumping = false
	elif (is_jumping && jump_timer.get_time_left() == 0.0):
		velocity += self.transform.origin.direction_to(moon.transform.origin) * gravity_area.gravity * 4.0
	
	# finally move the player
	velocity = self.move_and_slide(velocity, self.transform.basis.y, false, 1, 1.0)
	
	# rotate
	self.rotate(self.transform.basis.y, player_rotation * delta)
	
	# check collision
	for i in range(0, self.get_slide_count()):
		var collider = self.get_slide_collision(i).collider
		if (collider.is_in_group("enemy")):
			collider.emit_signal("kicked_by_player", collider)
		elif (collider.is_in_group("projectile")):
			print("hit by projectile!")

func take_damage(amount):
	self.health -= amount
	if (self.health <= 0):
		self.set_process(false)
		self.set_physics_process(false)
		self.emit_signal("player_died")
		animator.play("Die")

#func _on_animation_finished(name):
#	match name:
#		"Walk":
#			pass
#		"Jump":
#			pass
#		"Die":
#			self.emit_signal("player_died")
