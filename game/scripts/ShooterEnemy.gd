extends "res://game/scripts/Enemy.gd"

var projectile_type = null
var projectiles = null
var player = null

var lifetime = 0.0
var min_rate_of_fire = 0.2
var max_projectiles = 10
var last_direction = null

func _ready():
	player = self.get_parent().get_parent().get_node("Player")
	projectiles = self.get_parent().get_node("Projectiles")
	projectile_type = load("res://game/enemies/DamageOrb.tscn")
	
	timer.connect("timeout", self, "_on_timer_timeout")
	self.connect("landed_on_moon", self, "_on_moon_landing")

func _process(delta):
	lifetime += delta
	
	if (int(ceil(lifetime)) % 1000 == 0):
		var current_wait_time = timer.get_wait_time()
		if (current_wait_time * 0.8 <= min_rate_of_fire):
			self.set_process(false)
		else:
			timer.set_wait_time(current_wait_time * 0.8)

func _on_timer_timeout():
	if (player == null):
		pass
	
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

func _on_moon_landing(me):
	timer.start()
