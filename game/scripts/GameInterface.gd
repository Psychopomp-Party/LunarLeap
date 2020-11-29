extends Control

onready var label_time = self.get_node("LabelTime")
onready var label_points = self.get_node("LabelPoints")
onready var tree = self.get_tree()

var elapsed_time = 0.0

func _ready():
	label_points.set_text("0")
	label_time.set_text("0:00")

func _process(delta):
	elapsed_time += delta
	var secs = floor(elapsed_time)
	var millis = (elapsed_time - secs) * 100
	label_time.set_text("%d:%02d" % [secs, millis])
