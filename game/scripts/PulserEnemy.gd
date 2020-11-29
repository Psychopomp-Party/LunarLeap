extends "res://game/scripts/Enemy.gd"

onready var projectile_type = preload("res://game/enemies/DamageOrbTwo.tscn")

var min_rate_of_fire = 0.5
var rate_of_fire = 1.0
var last_direction = null
var ready = false

var time_between_animations = 0.0

func _ready():
	animator.connect("animation_finished", self, "_on_animation_finished")
	timer.connect("timeout", self, "_on_timer_timeout")

func _on_timer_timeout():
	if (player == null):
		pass
	
	if (ready):
		spawn_projectile(player)
	elif (!animator.is_playing()):
		animator.play("Pulse", -1, 2.0 - rate_of_fire)
		timer.start((2.0 - rate_of_fire) * 0.2)
		ready = true

func _on_animation_finished(anim):
	if (rate_of_fire * 0.9 > min_rate_of_fire):
		rate_of_fire *= 0.9
	
	animator.play("Pulse", -1, 2.0 - rate_of_fire)
	timer.start((2.0 - rate_of_fire) * 0.2)

func _on_impact(projectile, collider):
	if (projectile.get_parent() == null && collider.get_parent() == null):
		pass
	
	for group in collider.get_groups():
		match group:
			"enemy":
				projectile.get_parent().remove_child(projectile)
			"projectile":
				projectile.get_parent().remove_child(projectile)
				collider.get_parent().remove_child(collider)
			"player":
				projectile.get_parent().remove_child(projectile)
				collider.emit_signal("player_hit", 1)

func spawn_projectile(target):
	if (target == null):
		pass
	
	var direction = self.transform.origin.direction_to(target.transform.origin)
	if (last_direction == null):
		last_direction = direction
		pass
	
	var projectile = projectile_type.instance()
	projectile.transform.origin = self.transform.origin + direction
	projectiles.add_child(projectile)
	projectile.setup(target)
	
	projectile.connect("impact", self, "_on_impact")
	
	last_direction = direction

func get_points():
	return 10
