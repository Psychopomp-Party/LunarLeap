extends Node

onready var game_spatial = self.get_node("Spatial")
onready var game_control = self.get_node("Control")

var is_paused = false
var elapsed_time = 0.0

func _ready():
	game_spatial.connect("game_paused", self, "_on_game_paused")
	game_spatial.connect("game_unpaused", self, "_on_game_unpaused")

func _process(delta):
	if (is_paused):
		pass
	
	elapsed_time += delta
	game_control.get_node("LabelTime").set_text("%.2f" % elapsed_time)

func _on_game_paused():
	self.is_paused = true

func _on_game_unpaused():
	self.is_paused = false
