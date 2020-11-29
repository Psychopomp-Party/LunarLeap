extends RigidBody

var move_left = false
var move_right = false
var move_up = false
var move_down = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("player_move_left") && !move_left):
		move_left = true
		self.add_force(Vector3(100, 0, 0), Vector3(0, 0, 0))
	if (Input.is_action_pressed("player_move_right") && !move_right):
		move_right = true
		self.add_force(Vector3(-100, 0, 0), Vector3(0, 0, 0))
	if (Input.is_action_pressed("player_move_up") && !move_up):
		move_up = true
		self.add_force(Vector3(0, 100, 0), Vector3(0, 0, 0))
	if (Input.is_action_pressed("player_move_down") && !move_down):
		move_down = true
		self.add_force(Vector3(0, -100, 0), Vector3(0, 0, 0))
