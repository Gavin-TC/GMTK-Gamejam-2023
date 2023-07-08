extends CanvasLayer

func change_scene(target: String) -> void:
	var nodes = get_tree().get_nodes_in_group("Summon")
	for node in nodes:
		node.queue_free()
	$AnimationPlayer.play("dissolve")
	$TransitionAudio.play()
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards("dissolve")
