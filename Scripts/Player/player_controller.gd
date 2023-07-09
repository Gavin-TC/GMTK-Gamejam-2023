extends CharacterBody2D

@onready var ghost_summon = preload("res://Entities/ghost_summon.tscn")
@onready var ghost2_summon = preload("res://Entities/ghost_2_summon.tscn")
@onready var bat_summon = preload("res://Entities/bat_summon.tscn")

@onready var player_sprite = $PlayerSprite
@onready var footstep_player = $FootstepPlayer
@onready var summon_player = $SummonPlayer
@onready var animation_player = $AnimationPlayer
@onready var entrance_pointer_axis = $EntrancePointerAxis
@onready var entrance_pointer_node = $EntrancePointerAxis/EntracePointerNode
@onready var entrance_pointer_sprite = $EntrancePointerAxis/EntracePointerNode/Sprite2D
@onready var staff_sprite = $PlayerSprite/HandAxis/Hand/StaffSprite
@onready var death_audio = $DeathAudio
@onready var hit_audio = $HitAudio
@onready var healthbar = $HealthBar
@onready var manabar = $CanvasLayer/Control/ManaBar
@onready var summons_label = $CanvasLayer/Control/HBoxContainer/HBoxContainer2/SummonsLabel

@onready var ghost1_ui_icon = $CanvasLayer/Control/VBoxContainer/VBoxContainer3/HBoxContainer/HBoxContainer2/TextureRect
@onready var ghost2_ui_icon = $CanvasLayer/Control/VBoxContainer/VBoxContainer3/HBoxContainer/HBoxContainer2/TextureRect2
@onready var bat_ui_icon = $CanvasLayer/Control/VBoxContainer/VBoxContainer3/HBoxContainer/HBoxContainer2/TextureRect3

@onready var ghost1_icon = preload("res://Assets/Sprites and stuff/ghost_icon1.png")
@onready var ghost1_icon_selected = preload("res://Assets/Sprites and stuff/ghost_icon1_selected.png")
@onready var ghost2_icon = preload("res://Assets/Sprites and stuff/ghost_icon2.png")
@onready var ghost2_icon_selected = preload("res://Assets/Sprites and stuff/ghost_icon2_selected.png")
@onready var bat_icon = preload("res://Assets/Sprites and stuff/bat_icon3.png")
@onready var bat_icon_selected = preload("res://Assets/Sprites and stuff/bat_icon3_selected.png")

@onready var manabar_progress = preload("res://Assets/Sprites and stuff/manabar_progress.png")
@onready var red_flash = preload("res://Assets/Sprites and stuff/healthbar_progress.png")

#@onready var footstep_sound = "res://Assets/Audio/click_sound_footstep2.wav"
#@onready var summon_sound = "res://Assets/Audio/kenney_impact-sounds/Audio/impactBell_heavy_001.ogg"

@onready var entrance_node = get_tree().get_first_node_in_group("EntranceNode")

var speed = 400.0
var acceleration = 50.0
var friction = 20.0

var health = 100
var summon_mana = 100

var footstep_delay = 0.25
var count = 0

var cur_summons = 0
var max_summons = 5
# array of summons that are currently alive
var summons_out: Array[Summon] = []
var bodies = []
var selected_summon = 1  # 1-3
var kill_all_summons = false

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

var can_add = true

var can_die = true
var dying = false


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
	
	summons_label.text = str("SUMMONS\n" + str(cur_summons) + "/" + str(max_summons))
	
	if summon_mana < 100 and can_add and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		can_add = false
		
		summon_mana += 3
		
		await get_tree().create_timer(0.35).timeout
		can_add = true
	
	healthbar.value = health
	manabar.value = summon_mana
	
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
		footstep_player.pitch_scale = randf_range(0.9, 1.1)
		if footstep_player.playing == false:
			footstep_player.play()
		
		await get_tree().create_timer(footstep_delay).timeout
		
		can_footstep = true

func handle_summon():
	var summon_instance: Summon
	cur_summons = len(summons_out)
	
	if Input.is_action_just_pressed("one"):
		selected_summon = 1
	if Input.is_action_just_pressed("two"):
		selected_summon = 2
#	if Input.is_action_just_pressed("three"):
#		selected_summon = 3
	
	match selected_summon:
		1:
			summon_instance = ghost_summon.instantiate()
			ghost1_ui_icon.texture = ghost1_icon_selected
			ghost2_ui_icon.texture = ghost2_icon
			bat_ui_icon.texture = bat_icon
		2:
			summon_instance = ghost2_summon.instantiate()
			ghost1_ui_icon.texture = ghost1_icon
			ghost2_ui_icon.texture = ghost2_icon_selected
			bat_ui_icon.texture = bat_icon
		3:
			summon_instance = bat_summon.instantiate()
			ghost1_ui_icon.texture = ghost1_icon
			ghost2_ui_icon.texture = ghost2_icon
			bat_ui_icon.texture = bat_icon_selected
	
	if Input.is_action_pressed("kill_all") or kill_all_summons:
		kill_all_summons = true
		for summon in summons_out:
			summons_out.erase(summon)
			summon.kill()
		kill_all_summons = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_summon:
		can_summon = false
		can_count = true
		count = 0
		
		summon_player.pitch_scale = randf_range(0.9, 1.1)
		summon_player.play()
		
		if cur_summons < max_summons and summon_mana - summon_instance.summon_mana_decrement > 0:
			summon_instance.position = global_position + Vector2(randi_range(-40, 40), randi_range(-40, 40))
			summons_out.append(summon_instance)
			get_tree().get_root().add_child(summon_instance)
			
			summon_mana -= summon_instance.summon_mana_decrement
		elif summon_mana < summon_instance.summon_mana_decrement:
			manabar.texture_progress = red_flash
			await get_tree().create_timer(footstep_delay / 2).timeout
			manabar.texture_progress = manabar_progress
		elif cur_summons == max_summons:
			summons_label.add_theme_color_override("font_color", "RED")
			await get_tree().create_timer(footstep_delay / 2).timeout
			summons_label.add_theme_color_override("font_color", "7a6a71")
			
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
		entrance_pointer_axis.rotation = direction.angle()
	else:
		entrance_pointer_sprite.hide()

func kill():
	if max_summons == 0:
		print("YOU'RE DEAD")
#	if can_die:
#		can_die = false
#		dying = true
#
#		death_audio.pitch_scale = randf_range(0.9, 1.1)
#		if death_audio.playing == false:
#			death_audio.play()
#		if death_audio.playing == true:
#			await death_audio.finished
#			queue_free()
#
#func take_damage(damage):
#	if not dying:
#		health -= damage
#		hit_audio.pitch_scale = randf_range(0.8, 1.2)
#		hit_audio.play()
#		if health <= 0:
#			kill()

func _on_area_2d_body_entered(body):
	print(body)
	if body.is_in_group("Summon"):
		print("SUMMON ON CURSOR")
		kill_body = body
