extends Node2D

@onready var hero = preload("res://Entities/hero.tscn")

var can_start = true
var hero_alive = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hero_instance: CharacterBody2D = hero.instantiate()
	if Input.is_action_just_pressed("ui_accept") and can_start:
		can_start = false
		$CanvasLayer.hide()
		var spawn: Node2D = get_node("HeroSpawn")
		hero_instance.position = spawn.global_position
		self.add_child(hero_instance)
		hero_alive = true
	
	if hero_alive:
		if hero.is_queued_for_deletion():
			print("YOU WON!")
