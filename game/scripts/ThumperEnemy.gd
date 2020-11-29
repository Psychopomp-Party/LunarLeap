extends "res://game/scripts/Enemy.gd"

onready var projectile_type = preload("res://game/scenes/DamageOrbRed.tscn")

var min_rate_of_fire = 0.5
var rate_of_fire = 1.0
var ready = false

var time_between_animations = 0.0

func _on_timer_timeout():
	if (player == null):
		pass
	
	if (ready):
		spawn_projectile(player, projectile_type)
	elif (!animator.is_playing()):
		animator.play("Shoot", -1, 2.0 - rate_of_fire)
		timer.start((2.0 - rate_of_fire) * 0.2)
		ready = true

func _on_animation_finished(anim):
	if (rate_of_fire * 0.9 > min_rate_of_fire):
		rate_of_fire *= 0.9
	
	animator.play("Shoot", -1, 2.0 - rate_of_fire)
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

func get_points():
	return 10
