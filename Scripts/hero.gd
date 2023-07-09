extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var hit_audio = $hit_audio
@onready var death_audio = $death_audio
@onready var healthbar = $HealthBar

enum {
	TARGET_ENEMY,
	TARGET_STRUCTURE,
	ATTACK,
	NOT_ATTACK
}
var state = TARGET_STRUCTURE
var attack_state = NOT_ATTACK

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
#
#	print()
#	print(structure)
#	print(enemy)
#	print()
	
	if enemy:
		state = TARGET_ENEMY
	else:
		state = TARGET_STRUCTURE
	
	match state:
		TARGET_STRUCTURE:
			if structure and not enemy:
				print("structure")
				move(structure, delta, false)
			else:
				state = TARGET_ENEMY
		TARGET_ENEMY:
			if is_instance_valid(enemy) and not enemy.dying:
				print("enemy")
				move(enemy, delta, true)
			elif not enemy and structure:
				state = TARGET_STRUCTURE

func move(target, delta, aggressive:bool = false):
	if aggressive:
		var target_circle = get_circle_position(target[0])
		var global_target = target[0]
		
		var direction = (target_circle - global_position).normalized()
		var desired_velocity = direction * speed
		var steering = (desired_velocity - velocity) * delta * 2.5
		
		var destination_reached = false
		var distance = target_circle - global_position
		
		if distance.length() < 2:
			destination_reached = true
		
		if not destination_reached:
			velocity = desired_velocity
			attack_state = NOT_ATTACK
		else:
			attack_state = ATTACK
		
		# debug
		$DestinationRect.global_position = target_circle
			
		velocity.normalized()
		move_and_slide()
	elif target:
		var direction = (target[0].position - global_position).normalized()
		var desired_velocity = direction * speed
		var steering = (desired_velocity - velocity) * delta * 2.5
		print(move_and_slide())
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
		if targetted == "ENEMY" and is_instance_valid(enemy):
			enemy.take_damage(damage)

func detect_summon():
	var summons = []
	for nodes in get_tree().get_nodes_in_group("Summon"):
		print(nodes)

func handle_sprite_direction():
	if velocity.x < 0:
		print("right")
		sprite.scale.x = 5
	else:
		print("left")
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
