extends Node2D

@onready var hero = preload("res://Entities/hero.tscn")
@onready var win_node = $WinNode

var can_start = true
var hero_alive = false
var can_switch = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hero_instance: CharacterBody2D = hero.instantiate()
	var spawn: Node2D = get_node("HeroSpawn")
	hero_instance.position = spawn.global_position
	
	if Input.is_action_just_pressed("ui_accept") and can_start:
		can_start = false
		self.add_child(hero_instance)
		hero_alive = true
	
	if hero_alive:
		var hero_node = get_tree().get_nodes_in_group("Hero")
		if hero_node:
			var distance = hero_node[0].position - win_node.position
			
			print(distance.length())
			
			if not is_instance_valid(hero_node[0]):
				print("YOU WON!")
			if distance.length() < 50 and can_switch:
				can_switch = false
				SceneTransition.change_scene("res://Scenes/end_game.tscn")
