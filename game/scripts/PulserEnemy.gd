extends "res://game/scripts/Enemy.gd"

var projectile_type = null
var projectiles = null
var player = null

var min_rate_of_fire = 0.05
var last_direction = null
var times_attacked = 0

func _ready():
	player = self.get_parent().get_parent().get_node("Player")
	projectiles = self.get_parent().get_node("Projectiles")
	projectile_type = load("res://game/enemies/DamageRing.tscn")
	
	animator.connect("animation_finished", self, "_on_animation_finished")
	timer.connect("timeout", self, "_on_timer_timeout")
	self.connect("landed_on_moon", self, "_on_moon_landing")

func _on_timer_timeout():
	if (player == null):
		pass
	
	if (times_attacked % 10 == 0):
		timer.start(timer.get_wait_time() * 0.9)
	
	animator.play("Pulse", -1, 2.0 - timer.get_wait_time())

func _on_animation_finished(anim):
	print("pulser")
	match anim:
		"Pulse":
			spawn_projectile()
		_:
			print("pulser: ", anim)

func _on_moon_landing(me):
	timer.start()

func spawn_projectile():
	var direction = self.transform.origin.direction_to(player.transform.origin)
	if (last_direction == null):
		last_direction = direction
		pass
	
	var projectile = projectile_type.instance()
	projectile.transform.origin = self.transform.origin + direction
	projectile.shooter = self.get_instance_id()
	projectiles.add_child(projectile)
	projectile.add_central_force(last_direction * 1000.0)
	
	last_direction = direction
