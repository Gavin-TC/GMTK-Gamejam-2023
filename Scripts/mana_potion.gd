extends StaticBody2D

@onready var player = get_tree().get_first_node_in_group("Player")

var is_visible = false
var amount_to_give = 25

func _ready():
	$Sprite2D.modulate.a = 0
	$AnimationPlayer.play("bob_anim")

func _physics_process(delta):
	if $Sprite2D.modulate.a < 255:
		$Sprite2D.modulate.a = move_toward(0, 255, 5)

func _on_area_2d_body_entered(body):
	print(body)
	if body.is_in_group("Player"):
		if body.summon_mana < 100:
			if body.summon_mana + 25 > 100:
				var left_over = (body.summon_mana + amount_to_give) - 100
				amount_to_give -= left_over
				print(amount_to_give)
				print(body.summon_mana)
			body.summon_mana += amount_to_give
			queue_free()
