extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_audio = $hit_audio
@onready var death_audio = $death_audio
@onready var healthbar = $HealthBar
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

enum {
	TARGET_ENEMY,
	TARGET_STRUCTURE,
	ATTACK,
	NOT_ATTACK,
	WIN
}
var state = TARGET_STRUCTURE
var attack_state = NOT_ATTACK
var movement_target: Vector2

@onready var structure = get_tree().get_nodes_in_group("Structure")
@onready var enemy = get_tree().get_nodes_in_group("Summon")
@onready var win_node = get_tree().get_first_node_in_group("WinNode")

var targetted = "NONE"

var global_target = null

var speed = 300
var rand_num

var can_die = true
var dying = false

var health = 2000
var damage = 15

var can_print = true
var can_attack = true
var not_generated = true
var state_changed = false

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
	healthbar.value = health
	
	match attack_state:
		ATTACK:
			attack()
		NOT_ATTACK:
			pass
			
	if structure:
		if enemy and not state_changed:
			state = TARGET_ENEMY
		else:
			state = TARGET_STRUCTURE
	else:
		state = WIN
	
	match state:
		TARGET_STRUCTURE:
			print("attacking structure")
			if state_changed and structure or structure and not enemy:
				move(structure[0], delta, false)
			else:
				state = TARGET_ENEMY
		TARGET_ENEMY:
			if is_instance_valid(enemy[0]) and not enemy[0].dying:
#				if not_generated:
#					not_generated = false
#					var rng = RandomNumberGenerator.new()
#					var rand_num = rng.randi_range(1, 3)
#					print(rand_num)
#					state_changed = true
#					if rand_num == 1:
#						print("going back to attacK")
#						state = TARGET_STRUCTURE
				move(enemy[0], delta, true)
			elif not enemy and structure:
				state = TARGET_STRUCTURE
		WIN:
			can_attack = false
			move(win_node, delta, false)

func move(target, delta, aggressive:bool = false):
	if aggressive:
		if nav_agent.is_navigation_finished() and nav_agent.target_position:
			attack_state = ATTACK
			nav_agent.target_position = Vector2(0, 0)
		else:
			attack_state = NOT_ATTACK
		
		nav_agent.target_position = target.position
		
		var current_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		var new_velocity = next_path_position - current_position
		
		if new_velocity.length() > 50:
			new_velocity = new_velocity.normalized()
			new_velocity = new_velocity * speed
			velocity = new_velocity
		else:
			velocity = Vector2.ZERO
		
		move_and_slide()
	elif state == WIN:
		if nav_agent.is_navigation_finished() and nav_agent.target_position:
			can_attack = false
			attack_state = ATTACK
			nav_agent.target_position = Vector2(0, 0)
		else:
			attack_state = NOT_ATTACK
			
		if not nav_agent.target_position:
			nav_agent.target_position = target.position
		
		var current_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		var new_velocity = next_path_position - current_position
		
		if new_velocity.length() > 50:
			new_velocity = new_velocity.normalized()
			new_velocity = new_velocity * speed
			velocity = new_velocity
		else:
			velocity = Vector2.ZERO
		
		move_and_slide()
	elif target:
		if nav_agent.is_navigation_finished() and nav_agent.target_position:
			nav_agent.target_position = Vector2.ZERO
			attack_state = ATTACK
		else:
			state_changed = false
			attack_state = NOT_ATTACK
			
		if not nav_agent.target_position:
			nav_agent.target_position = target.position
		
		var next_path_position = nav_agent.get_next_path_position()
		var current_position = global_position
		var new_velocity = next_path_position - current_position
		
		if new_velocity.length() > 50:
			new_velocity = new_velocity.normalized()
			new_velocity = new_velocity * speed
			velocity = new_velocity
		else:
			velocity = Vector2.ZERO
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
	if can_attack:
		can_attack = false
		animation_player.stop()
		animation_player.play("swing_sword")
		if state == TARGET_ENEMY:
			enemy[0].take_damage(damage)
		elif state == TARGET_STRUCTURE:
			if structure:
				var distance_to_structure = structure[0].position - global_position
				if distance_to_structure.length() < 50:
					structure[0].take_damage(damage)
		
		await get_tree().create_timer(0.25).timeout
		can_attack = true

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
