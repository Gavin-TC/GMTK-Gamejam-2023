extends StaticBody2D
class_name Structure

@export var health: int = 50
@export var healthbar: TextureProgressBar

@onready var player = get_tree().get_first_node_in_group("Player")

var can_act = true
var can_kill = true

func _ready():
	healthbar.max_value = health
	healthbar.value = health

func _physics_process(delta):
	healthbar.value = health

func kill():
	print("max summons before " + str(player.max_summons))
	print("summons_out.length before " + str(len(player.summons_out)))
	
	print("can_act1 " + str(can_act))
	if can_act:
		can_act = false
		print("can_act2 " + str(can_act))
		if player.summons_out:
			player.summons_out[0].kill()
			player.summons_out.remove_at(0)
		player.max_summons -= 1
	
	print("max summons after " + str(player.max_summons))
	print("summons_out.length after " + str(len(player.summons_out)))
	
	queue_free()

func take_damage(damage):
	health -= damage
	if health <= 0:
		if can_kill:
			can_kill = false
			kill()
