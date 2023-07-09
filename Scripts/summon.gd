extends CharacterBody2D
class_name Summon
# This class is for entities that the player summons.

@export var sprite: Sprite2D
@export var hit_audio: AudioStreamPlayer2D
@export var death_audio: AudioStreamPlayer2D
@export var animation_player: AnimationPlayer
@export var summon_mana_decrement= 25
@export var health = 50.0
@export var speed = 50.0
@export var damage: int

@onready var mana_potion = preload("res://Entities/mana_potion.tscn")

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var hero: CharacterBody2D = get_tree().get_first_node_in_group("Hero")

var close_distance = Vector2(randi_range(100, 125), randi_range(100, 125))

var can_die = true
var dying = false
var can_attack = true

func _ready():
	randomize()

func _physics_process(delta):
	velocity = Vector2.ZERO
	
	if not animation_player.is_playing():
		animation_player.play("bob_anim")
	
	handle_wander()
	hero = get_tree().get_first_node_in_group("Hero")
	
	if velocity.x < 0:
		sprite.scale.x = -5
	else:
		sprite.scale.x = 5
	
	if dying:
		sprite.modulate.a = move_toward(sprite.modulate.a, 0, 0.15)
	move_and_slide()

func handle_wander():
	if player and not hero:
		var distance_to_player = player.position - position
	
		if distance_to_player > close_distance or distance_to_player < -close_distance:
			velocity.x = (player.position.x - position.x)
			velocity.y = (player.position.y - position.y)
	elif hero:
		var distance_to_hero = hero.position - position
		if distance_to_hero.length() > 100:
			velocity.x = (hero.position.x - position.x)
			velocity.y = (hero.position.y - position.y)
		else:
			velocity = Vector2.ZERO
			attack(hero)

func attack(target):
	if can_attack:
		can_attack = false
		hero.take_damage(damage)
		await get_tree().create_timer(0.5).timeout
		can_attack = true

func _on_velocity_computed(velocity):
	pass

func kill():
	if death_audio and can_die:
		can_die = false
		dying = true
		
		death_audio.pitch_scale = randf_range(0.9, 1.1)
		if death_audio.playing == false:
			death_audio.play()
		if death_audio.playing == true:
			await death_audio.finished
			player.summons_out.erase(self)
			
			var rand_num = randi_range(0, 3)
			if rand_num == 1:
				var mana_potion_instance = mana_potion.instantiate()
				mana_potion_instance.position = global_position
				get_tree().get_root().add_child(mana_potion_instance)
			
			queue_free()

func take_damage(damage):
	if not dying:
		health -= damage
		hit_audio.pitch_scale = randf_range(0.8, 1.2)
		hit_audio.play()
		if health <= 0:
			kill()

func _on_player_detector_body_entered(body):
#	if body.is_in_group("Player"):
#		player = body
#		player_detector.set_deferred("monitoring", false)
	pass

func _on_hero_detector_body_entered(body):
	if body.is_in_group("Hero"):
		hero = body
