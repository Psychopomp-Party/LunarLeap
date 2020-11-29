extends KinematicBody

signal moon_landing
signal enemy_hit(enemy)

onready var animator = self.get_node("AnimationPlayer")
onready var timer = self.get_node("Timer")

var player = null
var projectiles = null
var last_direction = null

var velocity = Vector3(0.0, 0.0, 0.0)
var gravity_point = Vector3(0.0, 0.0, 0.0)
var gravity = 10.0

func _ready():
	self.add_to_group("enemy")
	
	self.set_physics_process(false)
	
	self.connect("moon_landing", self, "_on_moon_landing")
	animator.connect("animation_finished", self, "_on_animation_finished")
	timer.connect("timeout", self, "_on_timer_timeout")

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

func _on_projectile_cleanup(projectile):
	pass
	#if (projectiles.get_child_count() >= 100):
	#	projectile.set_physics_process(false)
	#	projectile.get_parent().remove_child(projectile)

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

func spawn_projectile(target, projectile_type):
	var direction = self.transform.origin.direction_to(target.transform.origin)
	if (last_direction == null):
		last_direction = direction
		pass
	
	var projectile = projectile_type.instance()
	projectile.transform.origin = self.transform.origin# + direction
	projectiles.add_child(projectile)
	projectile.setup(target)
	
	projectile.connect("impact", self, "_on_impact")
	#projectile.connect("cleanup", self, "_on_projectile_cleanup")
	
	last_direction = direction
