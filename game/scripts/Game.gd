extends Node

onready var label_time = self.get_node("GameInterface/LabelTime")
onready var label_points = self.get_node("GameInterface/LabelPoints")
onready var life_bar = self.get_node("GameInterface/ProgressBar")
onready var enemies = self.get_node("GameScene/EnemySpawner/Enemies")
onready var player = self.get_node("GameScene/Player")
onready var tree = self.get_tree()

var points = 0

func _ready():
	player.connect("player_hit", self, "_on_player_hit")
	player.connect("player_died", self, "_on_player_death")
	player.connect("enemy_kicked", self, "_on_enemy_kicked")

func _process(delta):
	if (Input.is_action_just_pressed("game_pause") && player.health > 0):
		tree.paused = !tree.paused
		label_time.set_text("PAUSED")
	elif (Input.is_action_just_pressed("game_pause") && player.health <= 0):
		tree.paused = false
		tree.reload_current_scene()

func _on_player_hit(health):
	life_bar.set_value(health)

func _on_player_death():
	tree.paused = true
	label_time.set_text("dead")
	
func _on_enemy_kicked(enemy):
	points += enemy.get_points()
	label_points.set_text("%d" % self.points)
	
	enemies.remove_child(enemy)
