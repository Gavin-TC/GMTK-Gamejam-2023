extends CharacterBody2D

@onready var ghost_summon = preload("res://Entities/ghost_summon.tscn")
@onready var ghost2_summon = preload("res://Entities/ghost_2_summon.tscn")
@onready var spider_summon = preload("")

@onready var player_sprite = $PlayerSprite
@onready var footstep_player = $FootstepPlayer
@onready var summon_player = $SummonPlayer
@onready var animation_player = $AnimationPlayer
@onready var entrance_pointer_axis = $EntrancePointerAxis
@onready var entrance_pointer_node = $EntrancePointerAxis/EntracePointerNode
@onready var entrance_pointer_sprite = $EntrancePointerAxis/EntracePointerNode/Sprite2D

@onready var staff_sprite = $PlayerSprite/HandAxis/Hand/StaffSprite

#@onready var footstep_sound = "res://Assets/Audio/click_sound_footstep2.wav"
#@onready var summon_sound = "res://Assets/Audio/kenney_impact-sounds/Audio/impactBell_heavy_001.ogg"

@onready var entrance_node = get_tree().get_first_node_in_group("EntranceNode")

var speed = 400.0
var acceleration = 50.0
var friction = 20.0

var footstep_delay = 0.25
var count = 0

var cur_summons = 0
var max_summons = 5
# array of summons that are currently alive
var summons_out: Array[Summon] = []
var bodies = []

var kill_body = null
var body_close = Vector2(50, 50)

var moving = false
# can the player foostep
var can_footstep = true
# can a summon be spawned
var can_summon = true
# can 'staff counter' count
var can_count = true
# can a summon be killed
var can_kill = true


func _ready():
	randomize()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _physics_process(delta):
	if velocity:
		velocity.x = move_toward(velocity.x, 0, friction)
		velocity.y = move_toward(velocity.y, 0, friction)
	
	# technical
	handle_input()
	handle_sprite_dir()
	
	# gameplay oriented
	handle_footsteps()
	handle_summon()
	handle_summon_kill()
	handle_entrance_pointer()
	handle_summon_switch()
	
	velocity.normalized()
	move_and_slide()

func handle_input():
	if Input.is_action_pressed("up"):
		velocity.y = move_toward(velocity.y, -speed, acceleration)
	if Input.is_action_pressed("down"):
		velocity.y = move_toward(velocity.y, speed, acceleration)
	if Input.is_action_pressed("left"):
		velocity.x = move_toward(velocity.x, -speed, acceleration)
	if Input.is_action_pressed("right"):
		velocity.x = move_toward(velocity.x, speed, acceleration)
	
	if Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		moving = true
	else:
		moving = false

func handle_sprite_dir():
	if get_global_mouse_position() - position > Vector2.ZERO:
		player_sprite.scale.x = 5
	else:
		player_sprite.scale.x = -5

# the amount of footsteps played should be in proportion to the speed.
func handle_footsteps():
	if velocity and moving and can_footstep:
		can_footstep = false
		footstep_delay = 0.25
		
		## this doesn't really work that well.
#		var speed_ratio = velocity.normalized().length() / speed
#		footstep_delay = lerp(0.5, 0.25, speed_ratio*500)
		
		footstep_player.pitch_scale = randf_range(0.9, 1.1)
		if footstep_player.playing == false:
			footstep_player.play()
		
		await get_tree().create_timer(footstep_delay).timeout
		
		can_footstep = true

func handle_summon():
	cur_summons = len(summons_out)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_summon:
		can_summon = false
		can_count = true
		count = 0
		
		summon_player.pitch_scale = randf_range(0.9, 1.1)
		summon_player.play()
		
		if cur_summons < max_summons:
			var ghost_instance: Summon = ghost_summon.instantiate()
			ghost_instance.position = global_position + Vector2(randi_range(-40, 40), randi_range(-40, 40))
			summons_out.append(ghost_instance)
			get_tree().get_root().add_child(ghost_instance)
		
		if not animation_player.is_playing():
			animation_player.play("staff_anim")
		
		await get_tree().create_timer(footstep_delay).timeout
		
		can_summon = true
		
	if can_summon and can_count:
		can_count = false
		await get_tree().create_timer(1).timeout
		count += 1
		can_count = true 
		
		if count == 1:
			staff_sprite.rotation_degrees = 0
			can_count = false

func handle_summon_kill():
	if kill_body != null:
		var distance_to_body = get_global_mouse_position() - kill_body.global_position
		
		if distance_to_body < body_close or distance_to_body > -body_close:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				summons_out.erase(kill_body)
				kill_body.kill()
				kill_body == null

func handle_entrance_pointer():
	var hero_node = get_tree().get_first_node_in_group("Hero")
	if not hero_node:
		entrance_node = get_tree().get_first_node_in_group("EntranceNode")
	else:
		entrance_node = null
	
	if entrance_node:
		var direction = entrance_node.position - position
		var sprite_distance = entrance_node.position - entrance_pointer_sprite.global_position
		var pointer_max_x = 300
		
#		if sprite_distance.length() < 50:
#			print(max(sprite_distance.length(), pointer_max_x))
			
		entrance_pointer_axis.rotation = direction.angle()
	else:
		print(entrance_node)
		entrance_pointer_sprite.hide()

func handle_summon_switch():
	pass

func _on_area_2d_body_entered(body):
	print(body)
	if body.is_in_group("Summon"):
		print("SUMMON ON CURSOR")
		kill_body = body
