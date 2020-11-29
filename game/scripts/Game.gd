extends Node

onready var audio_player = self.get_node("GameInterface/AudioStreamPlayer")
onready var label_time = self.get_node("GameInterface/LabelTime")
onready var label_points = self.get_node("GameInterface/LabelPoints")
onready var life_bar = self.get_node("GameInterface/ProgressBar")
onready var enemies = self.get_node("GameScene/EnemySpawner/Enemies")
onready var player = self.get_node("GameScene/Player")
onready var tree = self.get_tree()

var points = 0

func _ready():
	player.connect("update_player_health", self, "_on_update_player_health")
	player.connect("player_died", self, "_on_player_death")
	player.connect("enemy_kicked", self, "_on_enemy_kicked")

func _process(delta):
	if (Input.is_action_just_pressed("game_pause") && player.health > 0):
		tree.paused = !tree.paused
		label_time.set_text("PAUSEd")
		if (tree.paused):
			audio_player.set_volume_db(-15.0)
		else:
			audio_player.set_volume_db(-10.0)
	elif (Input.is_action_just_pressed("game_restart") && player.health <= 0):
		tree.paused = false
		label_time.set_text("RESTARTING...")
		tree.reload_current_scene()
		randomize()

func _on_update_player_health(health):
	life_bar.set_value(health)

func _on_player_death():
	tree.paused = true
	label_time.set_text("dEAd")
	audio_player.set_volume_db(audio_player.get_volume_db() * 2.0)
	
func _on_enemy_kicked(enemy):
	points += enemy.get_points()
	label_points.set_text("%d" % self.points)
	
	enemies.remove_child(enemy)
