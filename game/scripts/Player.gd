extends KinematicBody

onready var moon = self.get_parent().get_node("Moon")
onready var moon_direction = self.translation.direction_to(moon.translation).normalized()

# movement variables
var should_move_left = false
var should_move_right = false
var should_move_up = false
var should_move_down = false

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
	
	moon_direction = self.translation.direction_to(moon.translation).normalized()
	#self.look_at(moon.translation, moon_direction)
	#self.rotate(self.rotation.cross(moon_direction).normalized(), self.rotation.dot(moon_direction))
	#self.transform = self.transform.orthonormalized()
	
	# 'gravity'
	self.move_and_collide((moon.translation - self.translation).normalized(), true, true, false)
	
	# keep updating movement while button is pressed
	if (should_move_left):
		print(">  ", self.rotation.dot(moon_direction))
		print(">> ", self.rotation.cross(moon_direction).normalized())
		self.move_and_slide(Vector3(10, 0, 0), Vector3(0, 1, 0), false, 8, 0.667, true)
		self.look_at(moon.translation, moon_direction)
	if (should_move_right):
		print(">  ", self.rotation.dot(moon_direction))
		print(">> ", self.rotation.cross(moon_direction).normalized())
		self.move_and_slide(Vector3(-10, 0, 0), Vector3(0, 1, 0), false, 8, 0.667, true)
		self.look_at(moon.translation, moon_direction)
	if (should_move_up):
		print(">  ", self.rotation.dot(moon_direction))
		print(">> ", self.rotation.cross(moon_direction).normalized())
		self.move_and_slide(Vector3(0, 10, 0), Vector3(0, 1, 0), false, 8, 0.667, true)
		self.look_at(moon.translation, moon_direction)
	if (should_move_down):
		print(">  ", self.rotation.dot(moon_direction))
		print(">> ", self.rotation.cross(moon_direction).normalized())
		self.move_and_slide(Vector3(0, -10, 0), Vector3(0, 1, 0), false, 8, 0.667, true)
		self.look_at(moon.translation, -moon_direction)
	
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
		should_move_up = true
	if (Input.is_action_just_released("player_move_up")):
		should_move_up = false
	if (Input.is_action_just_pressed("player_move_down")):
		should_move_down = true
	if (Input.is_action_just_released("player_move_down")):
		should_move_down = false
