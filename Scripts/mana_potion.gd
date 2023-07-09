extends StaticBody2D

@onready var player = get_tree().get_first_node_in_group("Player")

var is_visible = false

func _ready():
	$Sprite2D.modulate.a = 0
	$AnimationPlayer.play("bob_anim")

func _physics_process(delta):
	if $Sprite2D.modulate.a < 255:
		$Sprite2D.modulate.a = move_toward(0, 255, 25)

func _on_area_2d_body_entered(body):
	print(body)
	if body.is_in_group("Player"):
		body.summon_mana += 25
		queue_free()
