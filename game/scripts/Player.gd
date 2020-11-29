extends RigidBody

onready var gravity_area = self.get_parent().get_node("GravityModifier")
onready var camera = self.get_node("Camera")
onready var moon = self.get_parent().get_node("Moon")

var move_force = 10.0
var move_velocity = Vector3()
var jump_force = 0.5
var jump_velocity = Vector3()
var torque = Vector3()

func _ready():
	camera.global_transform.basis.z = -camera.global_transform.origin.direction_to(self.global_transform.origin)
	self.set_axis_lock(PhysicsServer.BODY_AXIS_ANGULAR_X, true)
	self.set_axis_lock(PhysicsServer.BODY_AXIS_ANGULAR_Z, true)

func _process(delta):
	if (Input.is_action_pressed("player_move_forward")):
		move_velocity = -self.transform.basis.z * move_force
	if (Input.is_action_pressed("player_move_backward")):
		move_velocity = self.transform.basis.z * move_force
	if (Input.is_action_just_pressed("player_move_jump")):
		jump_velocity = self.transform.basis.y * jump_force
	if (Input.is_action_just_released("player_move_jump")):
		jump_velocity = Vector3()

func _integrate_forces(state):
	# keep upright orientation
	state.transform.basis.y = -(moon.transform.origin - state.transform.origin).normalized()
	
	# apply gravity
	state.add_central_force(-state.transform.basis.y * 10)
	
	# apply movement
	state.add_central_force(move_velocity)
	
	if (state.get_contact_count() > 0):
		print(state.get_contact_collider_object(0) == moon)

func _physics_process(delta):
	if (self.linear_velocity != Vector3() && self.linear_velocity < move_velocity):
		self.add_central_force(move_velocity)
	self.apply_impulse(Vector3.UP, jump_velocity)
