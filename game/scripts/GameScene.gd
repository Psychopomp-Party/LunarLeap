extends Spatial

var elapsed_time = 0.0

signal elapsed_time(delta)

func _ready():
	pass

func _process(delta):
	elapsed_time += delta
	emit_signal("elapsed_time", elapsed_time)
