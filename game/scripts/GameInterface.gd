extends Control

onready var label_time = self.get_node("LabelTime")
onready var label_points = self.get_node("LabelPoints")
onready var life_bar = self.get_node("ProgressBar")
onready var audio_player = self.get_node("AudioStreamPlayer")
onready var tree = self.get_tree()

var elapsed_time = 0.0

func _ready():
	label_points.set_text("0")
	label_time.set_text("0:00")
	life_bar.set_value(10.0)
	
	audio_player.set_volume_db(-10.0)
	audio_player.connect("finished", self, "_on_audio_finished")

func _process(delta):
	elapsed_time += delta
	var secs = floor(elapsed_time)
	var millis = (elapsed_time - secs) * 100
	label_time.set_text("%d:%02d" % [secs, millis])
	
	if (secs == 0.0):
		audio_player.play(0.0)

func _on_audio_finished():
	# NOTE: Perhaps start a different song after one finishes?
	pass
