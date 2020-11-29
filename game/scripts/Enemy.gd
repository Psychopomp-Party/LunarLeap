extends KinematicBody

signal moon_landing
signal enemy_hit(enemy)

onready var animator = self.get_node("AnimationPlayer")
onready var timer = self.get_node("Timer")

var player = null
var projectiles = null

var velocity = Vector3(0.0, 0.0, 0.0)
var gravity_point = Vector3(0.0, 0.0, 0.0)
var gravity = 10.0

func _ready():
	self.add_to_group("enemy")
	
	self.set_physics_process(false)
	
	self.connect("moon_landing", self, "_on_moon_landing")

func _physics_process(delta):
	var collision = self.move_and_collide(velocity * delta)
	
	if (collision != null && collision.collider != null):
		var collider = collision.collider
		var groups = collider.get_groups()
		
		for group in collider.get_groups():
			match group:
				"enemy":
					self.emit_signal("enemy_hit", collider)
				"moon":
					self.emit_signal("moon_landing")
				_:
					continue

func _on_moon_landing():
	self.set_physics_process(false)
	timer.start()

func setup():
	player = self.get_parent().get_parent().get_parent().get_node("Player")
	projectiles = self.get_parent().get_parent().get_node("Projectiles")
	
	# orient
	var direction = self.transform.origin.direction_to(gravity_point)
	var enemy_down = -self.transform.basis.y
	var axis = enemy_down.cross(direction)
	var phi = enemy_down.angle_to(direction)
	if (axis.length_squared() == 0):
		axis = -self.transform.basis.z
	else:
		axis = axis.normalized()
		self.transform.basis = self.transform.basis.rotated(axis, phi)
		self.transform = self.transform.orthonormalized()
	
	# set velocity
	velocity = self.transform.origin.direction_to(gravity_point) * gravity
	
	self.set_physics_process(true)
