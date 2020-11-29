extends Node

onready var label_time = self.get_node("GameInterface/LabelTime")
onready var label_points = self.get_node("GameInterface/LabelPoints")
onready var enemy_handler = self.get_node("GameScene/Enemies")
onready var tree = self.get_tree()

var elapsed_time = 0.0
var points = 0

func _ready():
	enemy_handler.connect("points_earned", self, "_on_points_earned")

func _process(delta):
	if (!tree.paused):
		elapsed_time += delta
		label_time.set_text("%.2f" % elapsed_time)
	
	if (Input.is_action_just_pressed("game_pause")):
		tree.paused = !tree.paused
		label_time.set_text("PAUSED")

func _on_points_earned(points):
	self.points += points
	if ((self.points - (floor(self.points))) * 10 != 0):
		label_points.set_text("%.1f" % self.points)
	else:
		label_points.set_text("%d" % self.points)
