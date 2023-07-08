extends Area2D

var button_clickable = false

func _process(delta):
	if button_clickable:
		if Input.is_action_just_pressed("interact"):
			SceneTransition.change_scene("res://Scenes/dungeon_1.tscn")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		button_clickable = true
		$Prompt.show()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		button_clickable = false
		$Prompt.hide()
