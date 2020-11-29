extends RigidBody

func _ready():
	self.add_to_group("projectile")
	self.connect("body_entered", self, "_on_collision")

func _on_collision(body):
	var parent = self.get_parent()
	if (parent == null || parent.get_parent() == null):
		pass
	
	if (body.is_in_group("player")):
		# TODO: hurt player
		body.take_damage(1)
		parent.remove_child(self)
	elif (body.is_in_group("enemy") && parent != null && body != parent.get_parent()):
		# TODO: destroy enemy?
		parent.remove_child(self)
