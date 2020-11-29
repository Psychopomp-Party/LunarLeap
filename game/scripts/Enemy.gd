extends KinematicBody

var player_id = null
var moon_origin = Vector3(0.0, 0.0, 0.0)
var has_gravity = true

signal should_die

func spawn(player_id, moon_origin):
	self.player_id = player_id
	self.moon_origin = moon_origin
	var direction = self.transform.origin.direction_to(moon_origin)
	var down = -self.transform.basis.y
	var axis = down.cross(direction)
	var phi = down.angle_to(direction)
	if (axis.length_squared() == 0):
		axis = -self.transform.basis.z
	else:
		axis = axis.normalized()
		self.transform.basis = self.transform.basis.rotated(axis, phi)
		self.transform = self.transform.orthonormalized()

func _physics_process(delta):
	if (has_gravity):
		var velocity = self.transform.origin.direction_to(moon_origin) * 9.8
		var collision = self.move_and_collide(velocity)
		
		if (collision != null && self.player_id != null):
			if (collision.collider.get_class() == "KinematicBody"):
				emit_signal("should_die")
