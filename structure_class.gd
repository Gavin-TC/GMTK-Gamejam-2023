extends StaticBody2D
class_name Structure

@export var health: int = 50
@export var healthbar: TextureProgressBar

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready():
	healthbar.max_value = health
	healthbar.value = health

func _physics_process(delta):
	healthbar.value = health
	
	if Input.is_action_just_pressed("ui_accept"):
		take_damage(15)

func kill():
	print("max summons before " + str(player.max_summons))
	print("summons_out.length before " + str(len(player.summons_out)))
	
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
		kill()
