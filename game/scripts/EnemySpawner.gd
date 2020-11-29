extends Node

onready var player = self.get_parent().get_node("Player")
onready var moon = self.get_parent().get_node("Moon")
onready var timer = self.get_node("Timer")
onready var enemy_types = [
	preload("res://game/enemies/CapsuleEnemy.tscn"),
	preload("res://game/enemies/CubeEnemy.tscn")
]
var spawn_points = [
	Vector3(45.0,  0.0,  0.0),
	Vector3( 0.0, 45.0,  0.0),
	Vector3( 0.0,  0.0, 45.0),
	Vector3(-45.0, 0.0,  0.0),
	Vector3( 0.0,-45.0,  0.0),
	Vector3( 0.0,  0.0,-45.0)
]

var spawn_min_wait = 0.2
var spawn_wait_modifier = 0.025
var max_spawned_enemies = 50

func _ready():
	timer.start()

func _on_timer_timeout():
	# gradually speed up enemy spawn rate
	if (timer.get_wait_time() > spawn_min_wait):
		var old_wait_time = timer.get_wait_time()
		timer.set_wait_time(old_wait_time - (old_wait_time * spawn_wait_modifier))
	
	# spawn an enemy
	var enemy_count = self.get_child_count() - 1
	if (enemy_count < max_spawned_enemies):
		var spawner_index = randi() % spawn_points.size()
		var spawn_point = spawn_points[spawner_index]
		var enemy = enemy_types[randi() % enemy_types.size()].instance()
		enemy.transform.origin = spawn_point
		
		# orient the enemy
		enemy.spawn(player.get_instance_id(), moon.get_instance_id(), moon.transform.origin)
		
		# connect some enemy signals
		enemy.connect("landed_on_player", self, "_on_enemy_landed_on_player")
		enemy.connect("kicked_by_player", self, "_on_enemy_kicked_by_player")
		
		# add the enemy to the scene
		self.add_child(enemy)
		
		# move the spawner a bit
		randomize_spawner_position(spawner_index)
		
		print("Enemy count: ", self.get_child_count() - 1)

func randomize_spawner_position(index):
	var x1 = rand_range(-1.0, 1.0)
	var x2 = rand_range(-1.0, 1.0)
	
	while pow(x1, 2) + pow(x2, 2) >= 1:
		x1 = rand_range(-1.0, 1.0)
		x2 = rand_range(-1.0, 1.0)
	
	spawn_points[index] = Vector3(
		2 * x1 * sqrt(1 - pow(x1, 2) - pow(x2, 2)),
		2 * x2 * sqrt(1 - pow(x1, 2) - pow(x2, 2)),
		1 - 2 * (pow(x1, 2) + pow(x2, 2))) * 80.0 # or rand_range(60.0, 80.0)

func _on_enemy_landed_on_player(enemy):
	# TODO: play explosion animation
	self.remove_child(enemy)


func _on_enemy_kicked_by_player(enemy):
	self.remove_child(enemy)
