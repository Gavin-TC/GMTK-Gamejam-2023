extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var hit_audio = $hit_audio
@onready var death_audio = $death_audio
@onready var healthbar = $HealthBar
@onready var nav_agent = $NavigationAgent2D

enum {
	TARGET_ENEMY,
	TARGET_STRUCTURE,
	ATTACK,
	NOT_ATTACK
}
var state = TARGET_STRUCTURE
var attack_state = NOT_ATTACK
var movement_target: Vector2

@onready var structure = get_tree().get_nodes_in_group("Structure")
@onready var enemy = get_tree().get_nodes_in_group("Summon")
var targetted = "NONE"

var global_target = null

var speed = 300
var rand_num

var can_die = true
var dying = false

var health = 2000
var damage = 15

var can_print = true

func _ready():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	rand_num = rand.randf()
	healthbar.max_value = health
	nav_agent.path_desired_distance = 50.0
	nav_agent.target_desired_distance = 50.0

func _physics_process(delta):
	structure = get_tree().get_nodes_in_group("Structure")
	enemy = get_tree().get_nodes_in_group("Summon")
	
	handle_sprite_direction()
	detect_summon()
	healthbar.value = health
	
	match attack_state:
		ATTACK:
			attack()
		NOT_ATTACK:
			pass
	
	if enemy:
		state = TARGET_ENEMY
	else:
		state = TARGET_STRUCTURE
	
	match state:
		TARGET_STRUCTURE:
			if structure and not enemy:
				move(structure, delta, false)
			else:
				state = TARGET_ENEMY
		TARGET_ENEMY:
			if is_instance_valid(enemy[0]) and not enemy[0].dying:
				move(enemy, delta, true)
			elif not enemy and structure:
				state = TARGET_STRUCTURE

func move(target, delta, aggressive:bool = false):
	if aggressive:
		if nav_agent.is_navigation_finished() and nav_agent.target_position:
			attack_state = ATTACK
			nav_agent.target_position = Vector2(0, 0)
			print("finished")
		else:
			attack_state = NOT_ATTACK
		
		nav_agent.target_position = target[0].position
		
		var current_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		var new_velocity = next_path_position - current_position
		new_velocity = new_velocity.normalized()
		new_velocity = new_velocity * speed
		velocity = new_velocity
		move_and_slide()
#		var target_circle = get_circle_position(target[0])
#		var global_target = target[0]
#
#		var direction = (target_circle - global_position).normalized()
#		var desired_velocity = direction * speed
#		var steering = (desired_velocity - velocity) * delta * 2.5
#
#		var destination_reached = false
#		var distance = target_circle - global_position
#
#		if distance.length() < 2:
#			destination_reached = true
#
#		if not destination_reached:
#			velocity = desired_velocity
#			attack_state = NOT_ATTACK
#		# BASICALLY, IF ATTACKING STRUCTURE
#		else:
#			attack_state = ATTACK
#
#		# debug
#		$DestinationRect.global_position = target_circle
#
#		velocity.normalized()
#		velocity = desired_velocity
#		move_and_slide()
	elif target:
		if nav_agent.is_navigation_finished() and nav_agent.target_position:
			attack_state = ATTACK
			nav_agent.target_position = Vector2(0, 0)
		else:
			attack_state = NOT_ATTACK
			
		if not nav_agent.target_position:
			nav_agent.target_position = target[0].position
		
		var current_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		var new_velocity = next_path_position - current_position
		new_velocity = new_velocity.normalized()
		new_velocity = new_velocity * speed
		velocity = new_velocity
		move_and_slide()

func get_circle_position(target: CharacterBody2D):
	if not is_instance_valid(target):
		enemy = null
		global_target = null
		return Vector2(0, 0)
	
	var kill_circle_centre = target.global_position
	var direction = target.position - global_position
	var radius = -100
	var angle = direction.angle()
	var x = kill_circle_centre.x + cos(angle) * radius
	var y = kill_circle_centre.y + sin(angle) * radius
		
	return Vector2(x, y)

func attack():
	if not animation_player.is_playing():
		animation_player.play("swing_sword")
		if state == TARGET_ENEMY:
			enemy[0].take_damage(damage)
		elif state == TARGET_STRUCTURE:
			structure[0].take_damage(damage)

func detect_summon():
#	var summons = []
#	for nodes in get_tree().get_nodes_in_group("Summon"):
#		print(nodes)
	pass

func handle_sprite_direction():
	if velocity.x < 0:
		sprite.scale.x = 5
	else:
		sprite.scale.x = -5

func kill():
	if death_audio and can_die:
		can_die = false
		dying = true
		
		death_audio.pitch_scale = randf_range(0.9, 1.1)
		if death_audio.playing == false:
			death_audio.play()
		if death_audio.playing == true:
			await death_audio.finished
			queue_free()

func take_damage(damage):
	if not dying:
		health -= damage
		hit_audio.pitch_scale = randf_range(0.8, 1.2)
		hit_audio.play()
		if health <= 0:
			kill()

#func _on_enemy_detector_body_entered(body):
#	if body.is_in_group("Summon"):
#		enemy = body
#
#func _on_structure_detector_body_entered(body):
#	if body.is_in_group("Structure"):
#		structure = body
#
#func _on_player_detector_body_entered(body):
#	if body.is_in_group("Player"):
#		player = body
