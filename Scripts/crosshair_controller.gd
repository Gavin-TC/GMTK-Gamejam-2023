extends Sprite2D

var bodies = []

func _physics_process(_delta):
	global_position = get_global_mouse_position()
