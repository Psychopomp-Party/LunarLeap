extends KinematicBody

signal impact(projectile, collider)

var target = null

var velocity_scale = 15.0
var gravity_scale = velocity_scale * 1.2
var gravity_point = Vector3.ZERO
var initial_velocity = Vector3.ZERO
var initial_position = Vector3.ZERO

func _ready():
	self.add_to_group("projectile")
	
	self.set_physics_process(false)

func _physics_process(delta):
	self.orient()
	
	# physics
	var velocity = -self.transform.basis.z * velocity_scale
	velocity += self.transform.origin.direction_to(gravity_point) * gravity_scale
	velocity = self.move_and_slide(velocity, -self.transform.origin.direction_to(gravity_point))
	
	for i in range(self.get_slide_count()):
		var collider = self.get_slide_collision(i).collider
		for group in collider.get_groups():
			if (group == "player"):
				self.emit_signal("impact", self, collider)

func setup(target):
	self.target = target
	
	self.orient()
	self.look_at(target.transform.origin, self.transform.basis.y)
	
	self.set_physics_process(true)

func orient():
	var direction = self.transform.origin.direction_to(gravity_point)
	var down = -self.transform.basis.y
	var axis = down.cross(direction)
	var phi = down.angle_to(direction)
	if (axis.length_squared() == 0):
		axis = -self.transform.basis.z
	else:
		axis = axis.normalized()
		self.transform.basis = self.transform.basis.rotated(axis, phi)
		self.transform = self.transform.orthonormalized()
