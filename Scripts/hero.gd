extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var raycast = $Sprite2D/Hand/RayCast2D

enum {
	TARGET_ENEMY,
	TARGET_STRUCTURE,
	ATTACK,
	NOT_ATTACK
}
var state = TARGET_STRUCTURE
var attack_state = NOT_ATTACK

var player = null
var structure = null
var enemy = null
var targetted = "NONE"

var global_target = null

var speed = 300
var rand_num

func _ready():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	rand_num = rand.randf()

func _physics_process(delta):
	velocity = Vector2.ZERO
	
	handle_sprite_direction()
	
	match attack_state:
		ATTACK:
			attack()
		NOT_ATTACK:
			pass
	
	if player or enemy:
		state = TARGET_ENEMY
	
	match state:
		TARGET_STRUCTURE:
			if structure != null:
				move(structure, delta)
		TARGET_ENEMY:
			if enemy:
				if is_instance_valid(enemy):
					targetted = "Summon"
					move(enemy, delta, true)
			elif enemy == null and player:
				targetted = "Player"
				move(player, delta, true)
			else:
				targetted = "NONE"

func move(target: CharacterBody2D, delta, aggressive:bool = false):
	if aggressive:
		var target_circle = get_circle_position(target)
		var global_target = target
		
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
		
		$ColorRect.global_position = target_circle
			
		velocity.normalized()
		move_and_slide()
	elif target:
		var direction = (target.position - global_position).normalized()
		var desired_velocity = direction * speed
		var steering = (desired_velocity - velocity) * delta * 2.5
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
		if enemy and is_instance_valid(enemy):
			enemy.take_damage(5)
		elif player:
			player.take_damage(5)

func handle_sprite_direction():
	if velocity.x < 0:
		sprite.scale.x = 5
	else:
		sprite.scale.x = -5

func _on_enemy_detector_body_entered(body):
	if body.is_in_group("Summon"):
		enemy = body

func _on_structure_detector_body_entered(body):
	if body.is_in_group("Structure"):
		structure = body

func _on_player_detector_body_entered(body):
	if body.is_in_group("Player"):
		player = body
