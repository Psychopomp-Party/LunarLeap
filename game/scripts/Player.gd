extends KinematicBody

onready var gravity_area = self.get_parent().get_node("GravityModifier")
onready var camera = self.get_node("Camera")
onready var ray = self.get_node("RayCast")
onready var moon = self.get_parent().get_node("Moon")

var move_speed = 25.0
var velocity = Vector3(0.0, 0.0, 0.0)

var rotation_speed = 2.5
var player_rotation = 0.0

var jump_speed = 25.0
var is_jumping = false

func _ready():
	camera.global_transform.basis.z = -camera.global_transform.origin.direction_to(self.global_transform.origin)

func _process(delta):
	var movement = Vector3(0.0, 0.0, 0.0)
	var rot = 0.0
	if (Input.is_action_pressed("player_move_forward")):
		movement += -self.transform.basis.z * move_speed
	if (Input.is_action_pressed("player_move_backward")):
		movement += self.transform.basis.z * move_speed
	if (Input.is_action_pressed("player_move_left")):
		rot += rotation_speed
	if (Input.is_action_pressed("player_move_right")):
		rot += -rotation_speed
	if (Input.is_action_pressed("player_move_jump")):
		pass
	
	velocity = movement
	player_rotation = rot

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
	
	# apply gravity if not currently colliding with the moon
	# NOTE: this will probably only be necessary once jumping is implemented
	if (ray.is_colliding()):
		#velocity += -ray.get_collision_normal() * 10.
		pass
	else:
		#velocity += moon_direction * 10.0
		pass
	
	self.move_and_collide(velocity * delta)
	
	# rotate
	self.rotate(self.transform.basis.y, player_rotation * delta)
