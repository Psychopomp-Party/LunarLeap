extends "res://game/scripts/Enemy.gd"

onready var projectile_type = preload("res://game/enemies/DamageOrb.tscn")

var min_rate_of_fire = 0.15
var last_direction = null
var times_shot = 0

func _ready():
	animator.connect("animation_finished", self, "_on_animation_finished")
	timer.connect("timeout", self, "_on_timer_timeout")

func _on_timer_timeout():
	if (player == null):
		pass
	
	times_shot += 1
	if (timer.get_wait_time() > min_rate_of_fire && times_shot % 10 == 0):
		timer.start(timer.get_wait_time() * 0.9)
	
	animator.play("Shoot", -1, 2.0 - timer.get_wait_time())

func _on_animation_finished(anim):
	if (anim == "Shoot"):
		spawn_projectile(player)

func _on_impact(projectile, collider):
	if (projectile.get_parent() == null || collider.get_parent() == null):
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
				collider.emit_signal("player_hit", 2)

func spawn_projectile(target):
	var direction = self.transform.origin.direction_to(target.transform.origin)
	if (last_direction == null):
		last_direction = direction
		pass
	
	var projectile = projectile_type.instance()
	projectile.transform.origin = self.transform.origin + direction * 2.0
	projectiles.add_child(projectile)
	projectile.setup(target)
	
	projectile.connect("impact", self, "_on_impact")
	
	last_direction = direction

func get_points():
	return 1
