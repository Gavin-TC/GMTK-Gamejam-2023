extends StaticBody2D
class_name Structure

@export var health: int = 50
@export var healthbar: TextureProgressBar
@export var death_audio: AudioStreamPlayer2D
@export var hit_audio: AudioStreamPlayer2D
@export var sprite: Sprite2D

@onready var player = get_tree().get_first_node_in_group("Player")

var can_act = true
var can_die = true
var dying = false
var alive = true

func _ready():
	healthbar.max_value = health

func _physics_process(delta):
	healthbar.value = health
	if dying:
		sprite.modulate.a = move_toward(sprite.modulate.a, 0, 0.25)
		healthbar.modulate.a = move_toward(sprite.modulate.a, 0, 0.25)

func kill():
	if can_die:
		can_die = false
		dying = true
		
		if can_act:
			can_act = false
			print(player.summons_out)
			if player.summons_out:
				player.summons_out[0].kill()
				player.summons_out.remove_at(0)
			player.max_summons -= 1
			player.summons_label.add_theme_color_override("font_color", "RED")
			await get_tree().create_timer(player.footstep_delay / 2).timeout
			player.summons_label.add_theme_color_override("font_color", "7a6a71")
		
		death_audio.play()
		await death_audio.finished
		queue_free()

func take_damage(damage):
	if not dying:
		health -= damage
		hit_audio.pitch_scale = randf_range(0.8, 1.2)
		hit_audio.play()
		if health <= 0:
			kill()
