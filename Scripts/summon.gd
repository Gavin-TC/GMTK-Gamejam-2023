extends CharacterBody2D
class_name Summon
# This class is for entities that the player summons.

@export var sprite: Sprite2D
@export var death_audio: AudioStreamPlayer2D
@export var nav_agent: NavigationAgent2D
@export var player_detector: Area2D
@export var hero_detector: Area2D
@export var animation_player: AnimationPlayer
@export var summon_mana_decrement: int = 15
@export var health = 50.0
@export var speed = 50.0

var close_distance = Vector2(randi_range(100, 125), randi_range(100, 125))

var player = null
var hero = null

var damage = 1

var can_die = true
var dying = false

func _ready():
	randomize()

func _physics_process(delta):
	velocity = Vector2.ZERO
	
	if not animation_player.is_playing():
		animation_player.play("bob_anim")
	
	handle_wander()
	
	if dying:
		sprite.modulate.a = move_toward(sprite.modulate.a, 0, 0.15)
		if sprite.modulate.a == 0:
			queue_free()
	move_and_slide()

func handle_wander():
	if player and not hero:
		var distance_to_player = player.position - position
	
		if distance_to_player > close_distance or distance_to_player < -close_distance:
			velocity.x = (player.position.x - position.x)
			velocity.y = (player.position.y - position.y)
	elif hero:
		var distance_to_hero = hero.position - position
		if distance_to_hero.length() > 25:
			velocity.x = (player.position.x - position.x)
			velocity.y = (player.position.y - position.y)

func _on_velocity_computed(velocity):
	pass

func kill():
	if death_audio and can_die:
		can_die = false
		dying = true
		
		death_audio.pitch_scale = randf_range(0.9, 1.1)
		if death_audio.playing == false:
			death_audio.play()

func _on_player_detector_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_detector.set_deferred("monitoring", false)

func _on_hero_detector_body_entered(body):
	if body.is_in_group("Hero"):
		hero = body
