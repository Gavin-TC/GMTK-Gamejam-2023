extends CharacterBody2D

@onready var sprite = $Sprite2D

enum {
	TARGET_ENEMY,
	TARGET_STRUCTURE
}
var state = TARGET_STRUCTURE

var player = null
var structure = null
var enemies = []

var speed = 15

func _physics_process(delta):
	velocity = Vector2.ZERO
	
	handle_sprite_direction()
	
	if player or enemies:
		state = TARGET_ENEMY
	
	match state:
		TARGET_STRUCTURE:
			if structure != null:
				move(structure, delta)
		TARGET_ENEMY:
			if enemies:
				move(enemies[0], delta, true)
			elif player:
				move(player, delta, true)

func move(target, delta, aggressive:bool = false):
	if aggressive:
		print("AGGRESSIVE")
		var prev_target = target
		target = get_circle_position(prev_target)
		
		var direction = (target - global_position).normalized()
		var desired_velocity = direction * speed
		var steering = (desired_velocity - velocity) * delta * 2.5
		move_and_slide()
	else:
		var direction = (target.position - global_position).normalized()
		var desired_velocity = direction * speed
		var steering = (desired_velocity - velocity) * delta * 2.5
		move_and_slide()

func get_circle_position(target):
	print("CIRCLE: " + str(target.global_position))
	var kill_circle_centre = target.global_position
	var radius = 40
	var angle = randf() * PI * 2
	var x = kill_circle_centre.x + cos(angle) * radius
	var y = kill_circle_centre.y + sin(angle) * radius
	
	return Vector2(x, y)

func handle_sprite_direction():
	if velocity.x < 0:
		sprite.scale.x = -5
	else:
		sprite.scale.x = 5

func _on_enemy_detector_body_entered(body):
	if body.is_in_group("Summon"):
		print("summon")
		enemies.append(body)

func _on_structure_detector_body_entered(body):
	if body.is_in_group("Structure"):
		structure = body

func _on_player_detector_body_entered(body):
	if body.is_in_group("Player"):
		print("player")
		player = body
