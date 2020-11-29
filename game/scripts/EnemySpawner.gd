extends Node

onready var moon = self.get_parent().get_node("Moon")
onready var timer = self.get_node("Timer")
onready var enemy_types = [
	preload("res://game/enemies/CapsuleEnemy.tscn"),
	preload("res://game/enemies/CubeEnemy.tscn")
]
var spawn_points = [
	Vector3(75.0,  0.0,  0.0),
	Vector3( 0.0, 75.0,  0.0),
	Vector3( 0.0,  0.0, 75.0),
	Vector3(-75.0, 0.0,  0.0),
	Vector3( 0.0,-75.0,  0.0),
	Vector3( 0.0,  0.0,-75.0)
]
var enemies = []

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
	if (enemies.size() < max_spawned_enemies):
		var rand_index = randi() % spawn_points.size()
		var spawn_point = spawn_points[rand_index]
		var enemy = enemy_types[randi() % enemy_types.size()].instance()
		enemy.transform.origin = spawn_point
		enemy.scale(0.10)
		enemies.append(enemy)
		
		# orient the enemy
		var moon_direction = enemy.transform.origin.direction_to(moon.transform.origin)
		var enemy_down = -enemy.transform.basis.y
		var axis = enemy_down.cross(moon_direction)
		var phi = enemy_down.angle_to(moon_direction)
		if (axis.length_squared() == 0):
			axis = -enemy.transform.basis.z
		else:
			axis = axis.normalized()
			enemy.transform.basis = enemy.transform.basis.rotated(axis, phi)
			enemy.transform = enemy.transform.orthonormalized()
		
		# add the enemy to the scene
		self.add_child(enemy)
		
		# move the spawner a bit
		var x1 = rand_range(-1.0, 1.0)
		var x2 = rand_range(-1.0, 1.0)
		
		while pow(x1, 2) + pow(x2, 2) >= 1:
			x1 = rand_range(-1.0, 1.0)
			x2 = rand_range(-1.0, 1.0)
		
		spawn_points[rand_index] = Vector3(
			2 * x1 * sqrt(1 - pow(x1, 2) - pow(x2, 2)),
			2 * x2 * sqrt(1 - pow(x1, 2) - pow(x2, 2)),
			1 - 2 * (pow(x1, 2) + pow(x2, 2))) * rand_range(65.0, 75.0)

func _process(delta):
	#print(falling_enemies.size(), " ", enemies.size())
	pass

func _physics_process(delta):
	#for enemy in enemies:
	#	var gravity_direction = enemy.transform.origin.direction_to(moon.transform.origin)
	#	var velocity = enemy.move_and_slide(gravity_direction * 8, -gravity_direction)
	
	for enemy in enemies:
		# apply gravity
		var velocity = enemy.transform.origin.direction_to(moon.transform.origin) * 9.8
		velocity = enemy.move_and_slide(velocity, enemy.transform.basis.y)
