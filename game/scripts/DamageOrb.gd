extends KinematicBody

signal impact(projectile, collider)

var target = null

var velocity_scale = 5.0
var gravity_point = Vector3(0.0, 0.0, 0.0)
var gravity = 10.0

func _ready():
	self.add_to_group("projectile")

func _physics_process(delta):
	var direction = self.transform.origin.direction_to(target.transform.origin)
	var collision = self.move_and_collide(velocity_scale * direction * delta)
	
	if (collision != null && collision.collider != null):
		self.set_physics_process(false)
		self.emit_signal("impact", self, collision.collider)

func setup(target):
	self.target = target

func get_damage():
	return 1
