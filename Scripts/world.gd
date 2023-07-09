extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")

func _process(delta):
	player.max_summons = 0
