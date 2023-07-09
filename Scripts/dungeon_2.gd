extends Node2D

@onready var hero = preload("res://Entities/hero.tscn")
@onready var win_node = $WinNode

var can_start = true
var hero_alive = false
var hero_node
var can_go = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and can_start:
		can_start = false
		var hero_instance: CharacterBody2D = hero.instantiate()
		var spawn: Node2D = get_node("HeroSpawn")
		hero_instance.position = spawn.global_position
		
		self.add_child(hero_instance)
		hero_alive = true
		$CanvasLayer.hide()
	
	if hero_alive:
		var nodes = get_children()
		
		for node in nodes:
			if node.name == "Hero":
				hero_node = node
				
		if not is_instance_valid(hero_node):
			nodes = get_children()
			for node in nodes:
				if node.is_in_group("Summon"):
					node.queue_free()
			
			if can_go:
				can_go = false
				SceneTransition.change_scene("res://Scenes/end_game_win.tscn")
		elif hero_node:
			if is_instance_valid(hero_node):
				var distance = hero_node.position - win_node.position
				if distance.length() < 50:
					if can_go:
						can_go = false
						SceneTransition.change_scene("res://Scenes/end_game.tscn")
