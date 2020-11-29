extends KinematicBody

onready var camera = self.get_node("Camera")
onready var moon = self.get_parent().get_node("Moon")
onready var moon_direction = self.translation.direction_to(moon.translation)

# movement variables
var should_move_left = false
var should_move_right = false
var should_move_forward = false
var should_move_backward = false

func _ready():
	pass

func _physics_process(delta):
	# keep player 'upright'
	# perhaps try 'self.look_at' instead
	#ray.cast_to = -(moon.translation - self.translation).normalized()
	#self.rotate_x(ray.rotation.x)
	#self.rotate_y(ray.rotation.y)
	#self.rotate_z(ray.rotation.z)
	
	#self.look_at_from_position(self.translation, moon.translation, -(moon.translation - self.translation).normalized())
	#self.rotation = (moon.translation - self.translation).normalized()
	#if (self.rotation != old_rotation):
	#	print("Pointed rotation: ", (moon.translation - self.translation).normalized())
	
	moon_direction = self.translation.direction_to(moon.translation)
	#self.transform.basis.y = -moon_direction
	
	#if (moon_direction.cross(self.transform.basis.y).normalized() != Vector3(0, 0, 0)):
	#	print(moon_direction.cross(self.transform.basis.y).normalized())
	#	self.rotate(moon_direction.cross(self.transform.basis.y).normalized(), self.transform.basis.y.angle_to(moon.translation))
	
	#self.rotate(self.rotation.cross(moon_direction).normalized(), self.rotation.dot(moon_direction))
	#self.transform = self.transform.orthonormalized()
	
	# 'gravity'
	self.move_and_collide((moon.translation - self.translation).normalized(), true, true, false)
	#self.rotate(self.transform.basis.x, moon_direction.x)
	
	# keep updating movement while button is pressed
	if (should_move_left):
		print(">  ", self.rotation.dot(moon_direction))
		print(">> ", self.transform.basis.y.cross(moon_direction).normalized())
		#self.move_and_slide(Vector3(-10, 0, 0), -moon_direction, false, 8, 0.667, true)
		self.rotate(self.transform.basis.y, 0.015)
	if (should_move_right):
		print(">  ", self.rotation.dot(moon_direction))
		print(">> ", self.rotation.cross(moon_direction).normalized())
		#self.move_and_slide(Vector3(10, 0, 0), -moon_direction, false, 8, 0.667, true)
		self.rotate(self.transform.basis.y, -0.015)
	if (should_move_forward):
		print(">  ", self.rotation.dot(moon_direction))
		print(">> ", self.rotation.cross(moon_direction).normalized())
		self.move_and_slide(-self.transform.basis.z * 10, -moon_direction, false, 8, 0.667, true)
	if (should_move_backward):
		print(">  ", self.rotation.dot(moon_direction))
		print(">> ", self.rotation.cross(moon_direction).normalized())
		self.move_and_slide(self.transform.basis.z * 10, -moon_direction, false, 8, 0.667, true)
	
	# set whether the player should move when a button is pressed
	if (Input.is_action_just_pressed("player_move_left")):
		should_move_left = true
	if (Input.is_action_just_released("player_move_left")):
		should_move_left = false
	if (Input.is_action_just_pressed("player_move_right")):
		should_move_right = true
	if (Input.is_action_just_released("player_move_right")):
		should_move_right = false
	if (Input.is_action_just_pressed("player_move_up")):
		should_move_forward = true
	if (Input.is_action_just_released("player_move_up")):
		should_move_forward = false
	if (Input.is_action_just_pressed("player_move_down")):
		should_move_backward = true
	if (Input.is_action_just_released("player_move_down")):
		should_move_backward = false
