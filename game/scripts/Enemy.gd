extends KinematicBody

var player_id = null
var moon_id = null
var moon_origin = Vector3(0.0, 0.0, 0.0)
var has_gravity = true

signal landed_on_player(me)
signal landed_on_enemy(me)
signal landed_on_moon(me)
signal kicked_by_player(me)

func spawn(player_id, moon_id, moon_origin):
	self.player_id = player_id
	self.moon_id = moon_id
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
		var collision = self.move_and_collide(velocity * delta)
		
		if (collision != null && self.player_id != null):
			var collider = collision.collider
			if (collider.get_instance_id() == self.player_id):
				emit_signal("landed_on_player", self)
			elif (collider.get_instance_id() == self.moon_id):
				emit_signal("landed_on_moon", self)
				self.has_gravity = false
			elif (collider.get_class() == "KinematicBody"):
				emit_signal("landed_on_enemy", self)

func get_point_value():
	if ("Shooter" in self.name):
		return 1
	elif ("Pulse" in self.name):
		return 2
	else:
		print("####", self.name)
		return 0
