extends StaticBody2D
class_name Structure

@export var health: int = 50
@export var healthbar: TextureProgressBar
@export var audio_player: AudioStreamPlayer2D

@onready var player = get_tree().get_first_node_in_group("Player")

var can_act = true
var can_kill = true
var alive = true

func _ready():
	healthbar.max_value = health

func _physics_process(delta):
	if alive:
		healthbar.value = health

func kill():
	print("max summons before " + str(player.max_summons))
	print("summons_out.length before " + str(len(player.summons_out)))
	
	print("can_act1 " + str(can_act))
	if can_act:
		can_act = false
		print("can_act2 " + str(can_act))
		print(player.summons_out)
		if player.summons_out:
			player.summons_out[0].kill()
			player.summons_out.remove_at(0)
		player.max_summons -= 1
	
	print("max summons after " + str(player.max_summons))
	print("summons_out.length after " + str(len(player.summons_out)))
	
	audio_player.play()
	queue_free()
	await audio_player.finished

func take_damage(damage):
	health -= damage
	if health <= 0:
		if can_kill:
			can_kill = false
			kill()
