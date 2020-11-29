extends Node

onready var player = self.get_parent().get_node("Player")
onready var enemies = self.get_node("Enemies")
onready var projectiles = self.get_node("Projectiles")
onready var moon = self.get_parent().get_node("Moon")
onready var timer = self.get_node("Timer")
onready var enemy_types = [
	preload("res://game/scenes/PulserEnemy.tscn"),
	preload("res://game/scenes/ThumperEnemy.tscn")
]
var spawn_points = [
	Vector3(45.0,  0.0,  0.0),
	Vector3( 0.0, 45.0,  0.0),
	Vector3( 0.0,  0.0, 45.0),
	Vector3(-45.0, 0.0,  0.0),
	Vector3( 0.0,-45.0,  0.0),
	Vector3( 0.0,  0.0,-45.0)
]

var min_wait_time = 0.1
var wait_modifier = 0.8
var max_spawned_enemies = 10
var max_active_projectiles = 150

func _ready():
	randomize()
	for spawn_point in range(0, spawn_points.size()):
		randomize_spawner_position(spawn_point)
	
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()

func _on_timer_timeout():
	# gradually speed up enemy spawn rate
	if (timer.get_wait_time() > min_wait_time):
		var old_wait_time = timer.get_wait_time()
		timer.set_wait_time(timer.get_wait_time() * wait_modifier)
	
	# spawn an enemy
	var enemy_count = enemies.get_child_count() - 1
	if (enemy_count < max_spawned_enemies):
		var spawner_index = randi() % spawn_points.size()
		var spawn_point = spawn_points[spawner_index]
		var enemy = enemy_types[randi() % enemy_types.size()].instance()
		enemy.transform.origin = spawn_point
		
		# add the enemy to the scene
		enemies.add_child(enemy)
		
		# orient and set enemy's initial velocity
		enemy.setup()
		
		# just remove enemies that land on other enemies
		enemy.connect("enemy_hit", self, "_on_enemy_kicked")
		
		# move the spawner a bit
		randomize_spawner_position(spawner_index)
	
	# clean up projectiles
	# TODO: try to clean up only a few out of view, use `VisibilityNotifier`s
	if (projectiles.get_child_count() >= max_active_projectiles):
		for projectile in projectiles.get_children():
			if (projectile.transform.origin.distance_to(player.transform.origin) >= 40.0):
				projectile.set_physics_process(false)
				projectiles.remove_child(projectile)

func _on_enemy_kicked(enemy):
	enemies.remove_child(enemy)

func randomize_spawner_position(index):
	var x1 = rand_range(-1.0, 1.0)
	var x2 = rand_range(-1.0, 1.0)
	
	while pow(x1, 2) + pow(x2, 2) >= 1:
		x1 = rand_range(-1.0, 1.0)
		x2 = rand_range(-1.0, 1.0)
	
	spawn_points[index] = Vector3(
		2 * x1 * sqrt(1 - pow(x1, 2) - pow(x2, 2)),
		2 * x2 * sqrt(1 - pow(x1, 2) - pow(x2, 2)),
		1 - 2 * (pow(x1, 2) + pow(x2, 2))) * 80.0
