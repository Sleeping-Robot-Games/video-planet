extends Node2D

@onready var vcr = $VCR
@onready var tracking = $VCR/Tracking
@onready var tick_path_follow = $VCR/Ticker/Path2D/TickPathFollow2D
@onready var hitzone_path_follow = $VCR/Ticker/Path2D/HitzonePathFollow2D
@onready var hitzone = $VCR/Ticker/Path2D/HitzonePathFollow2D/HitZone
@onready var dial = $VCR/Dial
@onready var dial_light = $VCR/DialLight
@onready var rewind_button = $VCR/RewindButton
@onready var tv = $TV/Sprite2D
@onready var left_spool = $VCR/SpoolIndicator
@onready var right_spool = $VCR/SpoolIndicator2
@onready var anim_player = $VCR/AnimationPlayer 
@onready var broken_tape = $BrokenTape
@onready var fix_tape_button = $FixTapeButton
@onready var rewind_effect: ColorRect = $SubViewportContainer/SubViewport/RewindEffectRect
@onready var tv_off_screen = $SubViewportContainer/SubViewport/TVOff
@onready var video_player = $SubViewportContainer/SubViewport/VideoStreamPlayer
@onready var lives_light_container = $VCR/LivesLightContainer

const DIAL_ROTATE_SPEED = 50.0
const DIAL_ROTATE_MIN = -100.0
const DIAL_ROTATE_MAX = 100.0

var dial_angle = 0.0

var tracking_input_map = {
	"1": null,
	"2": null,
	"3": null,
	"4": null,
	"5": null,
}

var tick_speed = 0
var tick_direction := 1.0 # 1 = forward, -1 = backward

var tick_in_hitzone = false
# how wide the hitzone is based on the track setting weight
var hitzone_scale_lookup = {
	2: .05,
	1: .1,
	0: .25,
}

var current_ideal_track_setting
var current_toggled_track_setting

var num_of_misses = 0

var rewinding = false
var vhs_phase = 1
var successful_hits = 0

## Right now the VHS needs 8 successes total based on the spool scale math
var VHS_DATA = {
	# The number of miss tick failures before the VHS breaks
	'number_of_failures_before_break': 5,
	1: {
		# the track weight setting of 0 is best and 2 is worst
		'track_setting_weights': {
			"1": 1,
			"2": 0,
			"3": 1,
			"4": 2,
			"5": 2
		},
		# the dial zone is the area between 2 rotation degrees between -100 and 100
		'dial_zone': {
			'rough_zone': [40, 80],  # yellow light
			'tight_zone': [50, 60]   # green light
		},
		# how fast the tick goes across the track based on dial_zone
		'tick_speeds': {
			'no_zone': 1.4,
			'rough_zone': 1.2,
			'tight_zone': 1
		},
		# position of hitzone on the path between 0 and 1
		'hitzone_position': .4,
		# number of times the player needs to hit with the tick in the hitzone to move to the next phase
		'success_count_to_continue': 2,
	},
	2: {
		'track_setting_weights': {
			"1": 1,
			"2": 2,
			"3": 2,
			"4": 1,
			"5": 0
		},
		'dial_zone': {
			'rough_zone': [-10, 30],
			'tight_zone': [-5, 5]
		},
		'tick_speeds': {
			'no_zone': 1.8,
			'rough_zone': 1.4,
			'tight_zone': 1
		},
		'hitzone_position': .6,
		'success_count_to_continue': 4,
	},
	3: {
		'track_setting_weights': {
			"1": 2,
			"2": 1,
			"3": 0,
			"4": 1,
			"5": 2
		},
		'dial_zone': {
			'rough_zone': [-70, -40],
			'tight_zone': [-55, -50]
		},
		'tick_speeds': {
			'no_zone': 1.9,
			'rough_zone': 1.5,
			'tight_zone': 1
		},
		'hitzone_position': .2,
		'success_count_to_continue': 2,
	}
}


func _ready():
	a.play_music('backroom_bmg_1')
	for tracking_button in tracking.get_children():
		tracking_button.pressed.connect(_on_tracking_button_pressed.bind(tracking_button.name))
		tracking_input_map[tracking_button.name] = tracking_button

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('fix'):
		fix_tape_button.pressed.emit()
	
	if event.is_action_pressed('rewind'):
		rewind_button.pressed.emit()
		
	if not rewinding:
		return
		
	for key in tracking_input_map.keys():
		if event.is_action_pressed(key):
			tracking_input_map[key].button_pressed = true
			tracking_input_map[key].pressed.emit()
			
	if event.is_action_pressed('hit'):
		if tick_in_hitzone:
			successful_hits += 1
			if successful_hits >= VHS_DATA[vhs_phase].success_count_to_continue:
				next_vhs_phase()
			on_success()
		else:
			on_miss()
	

func _process(delta):
	if not rewinding:
		return
		
	if Input.is_action_pressed('dial_right'):
		dial_angle += DIAL_ROTATE_SPEED * delta
	elif Input.is_action_pressed('dial_left'):
		dial_angle -= DIAL_ROTATE_SPEED * delta
	
	dial_angle = clamp(dial_angle, DIAL_ROTATE_MIN, DIAL_ROTATE_MAX)
	dial.rotation_degrees = dial_angle
	
	var dial_zone = VHS_DATA[vhs_phase].dial_zone
	
	if dial.rotation_degrees >= dial_zone.tight_zone[0] and dial.rotation_degrees <= dial_zone.tight_zone[1]:
		dial_light.color = Color.GREEN
		tick_speed = VHS_DATA[vhs_phase].tick_speeds['tight_zone']
	elif dial.rotation_degrees >= dial_zone.rough_zone[0] and dial.rotation_degrees <= dial_zone.rough_zone[1]:
		dial_light.color = Color.YELLOW
		tick_speed = VHS_DATA[vhs_phase].tick_speeds['rough_zone']
	else:
		dial_light.color = Color.BLACK
		tick_speed = VHS_DATA[vhs_phase].tick_speeds['no_zone']
	
	tick_path_follow.progress_ratio += tick_speed * delta * tick_direction

	if tick_path_follow.progress_ratio >= 1.0:
		tick_path_follow.progress_ratio = 1.0
		tick_direction = -1.0
	elif tick_path_follow.progress_ratio <= 0.0:
		tick_path_follow.progress_ratio = 0.0
		tick_direction = 1.0

func on_success():
	if not rewinding:
		return
		
	anim_player.pause()

	var left_spool_rot = left_spool.rotation
	var right_spool_rot = right_spool.rotation

	var rotation_tween = create_tween()

	# Both spools spin fast, full rotation in opposite directions
	var full_rot := deg_to_rad(360)
	rotation_tween.tween_property(left_spool, "rotation", left_spool_rot - full_rot, 0.35)
	rotation_tween.parallel().tween_property(right_spool, "rotation", right_spool_rot - full_rot, 0.35)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(left_spool, "scale", left_spool.scale + Vector2(.2, .2), .35)
	scale_tween.parallel().tween_property(right_spool, "scale", right_spool.scale - Vector2(.2, .2), .35)
	
	if rewinding:
		# Step 2: resume main spin animation
		rotation_tween.tween_callback(Callable(anim_player, "play").bind("spin"))


func on_miss():
	if not rewinding:
		return
		
	num_of_misses += 1
	
	anim_player.pause()

	var left_spool_rot = left_spool.rotation
	var right_spool_rot = right_spool.rotation

	# Calculate reel-back offset (both rotate opposite directions)
	var offset := deg_to_rad(60)

	var rotation_tween := create_tween()

	# Reel back (simulate tape tension shift)
	rotation_tween.tween_property(left_spool, "rotation", left_spool_rot + offset, 0.15)
	rotation_tween.parallel().tween_property(right_spool, "rotation", right_spool_rot + offset, 0.15)

	# Return to original rotation
	rotation_tween.tween_property(left_spool, "rotation", left_spool_rot, 0.2)
	rotation_tween.parallel().tween_property(right_spool, "rotation", right_spool_rot, 0.2)
	
	# Shake VCR
	## TODO: intesify shake as number of misses grows
	var original_position = vcr.position
	var shake_tween := create_tween()
	shake_tween.tween_property(vcr, 'position', vcr.position + Vector2(5, 0), .117)
	shake_tween.tween_property(vcr, 'position', vcr.position - Vector2(5, 0), .117)
	shake_tween.tween_property(vcr, 'position', original_position, .117)
	
	turn_off_next_light()
	
	if num_of_misses >= VHS_DATA.number_of_failures_before_break:
		broken_tape.show()
		fix_tape_button.show()
		rewinding = false
		tv_off_screen.show()
		video_player.paused = true
	else:
		# Resume the spin loop
		rotation_tween.tween_callback(Callable(anim_player, "play").bind("spin"))


func _on_tracking_button_pressed(track_setting: String):
	if not rewinding:
		return
		
	current_toggled_track_setting = track_setting
	var current_tracking_setting_weight = VHS_DATA[vhs_phase].track_setting_weights[current_toggled_track_setting]
	var new_scale = Vector2(hitzone_scale_lookup[current_tracking_setting_weight], .328)
	var hitzone_tween = create_tween()
	hitzone_tween.tween_property(hitzone, 'scale', new_scale, .5)
	
	update_rewind_noise_by_tracking_setting()
	
	
func update_rewind_noise_by_tracking_setting():
	var current_tracking_setting_weight = VHS_DATA[vhs_phase].track_setting_weights[current_toggled_track_setting]

	var chosen = int(current_tracking_setting_weight)

	var noise_value := 0.2 # Default 
	if chosen == 1:
		noise_value = 0.06
	elif chosen >= 2:
		noise_value = 0.02

	set_rewind_noise(noise_value)

	
func _on_hitzone_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().name == 'Tick':
		tick_in_hitzone = true


func _on_hitzone_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().name == 'Tick':
		tick_in_hitzone = false

func init_vhs():
	vhs_phase = 1
	hitzone_path_follow.progress_ratio = VHS_DATA[vhs_phase].hitzone_position
	current_ideal_track_setting = get_best_track_setting_for_phase(vhs_phase)
	rewinding = true
	anim_player.play('spin')
	tv_off_screen.hide()
	video_player.play()
	set_rewind_noise()
	turn_on_live_lights()
	
	var hitzone_scale_tween = create_tween()
	hitzone_scale_tween.tween_property(hitzone, 'scale', Vector2(hitzone_scale_lookup[2], .328), 1)
	
	var tick_speed_tween = create_tween()
	tick_speed_tween.tween_property(self, 'tick_speed', VHS_DATA[vhs_phase].tick_speeds['no_zone'], 1)
	
	
func start_vhs_rewind_after_fix():
	num_of_misses = 0
	broken_tape.hide()
	broken_tape.rotation_degrees = -180
	broken_tape.modulate = Color.RED
	fix_tape_button.hide()
	rewinding = true
	$VCR/AnimationPlayer.play('spin')
	tv_off_screen.hide()
	video_player.play()
	set_rewind_noise()
	turn_on_live_lights()


func next_vhs_phase():
	successful_hits = 0
	vhs_phase += 1
	if not VHS_DATA.has(vhs_phase):
		rewinding = false
		$VCR/AnimationPlayer.pause()
		video_player.stop()
		tv_off_screen.show()
		## TODO: Reset tracking button and dial state
		## TODO: Success label/button to restock completed tape.
		## Player can now select a new tape from the backlog or leave back to the store front
		## TODO: make button to go back to store front
	else:
		hitzone_path_follow.progress_ratio = VHS_DATA[vhs_phase].hitzone_position
		current_ideal_track_setting = get_best_track_setting_for_phase(vhs_phase)
		
		update_rewind_noise_by_tracking_setting()
		
		var hitzone_scale_tween = create_tween()
		hitzone_scale_tween.tween_property(hitzone, 'scale', Vector2(hitzone_scale_lookup[VHS_DATA[vhs_phase].track_setting_weights[current_toggled_track_setting]], .328), 1)
		
		var tick_speed_tween = create_tween()
		tick_speed_tween.tween_property(self, 'tick_speed', VHS_DATA[vhs_phase].tick_speeds['no_zone'], 1)
		
		
func _on_rewind_button_pressed() -> void:
	if rewinding:
		return 
		
	init_vhs()
	rewind_button.release_focus()

func get_best_track_setting_for_phase(phase: int) -> String:
	var track_weights = VHS_DATA[phase].track_setting_weights

	for track_number in track_weights.keys():
		if track_weights[track_number] == 0:
			return track_number

	# fallback if no weight 0 found
	push_error("No weight 0 found for phase %s" % str(phase))
	return ""


func _on_fix_tape_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(broken_tape, 'rotation', 0, 4)
	tween.parallel().tween_property(broken_tape, 'modulate', Color.WHITE, 4)
	tween.tween_callback(Callable(self, "start_vhs_rewind_after_fix"))

func set_rewind_noise(value: float = .02) -> void:
	# Get the ShaderMaterial on the VCR effect
	var mat := rewind_effect.material
	if mat == null:
		return
	
	# Get the noise texture uniform (must match your shader uniform name!)
	var noise_tex: NoiseTexture2D = mat.get_shader_parameter("noise_texture")
	if noise_tex == null:
		return
	
	var noise := noise_tex.noise as FastNoiseLite
	if noise == null:
		push_warning("noise_texture does not use FastNoiseLite")
		return

	# Adjust frequency
	noise.frequency = value

	# Apply change
	noise_tex.noise = noise
	
func turn_off_next_light():
	var lives_lights = lives_light_container.get_children()
	lives_lights.reverse()
	for light in lives_lights:
		if light.color == Color.GREEN:
			light.color = Color.BLACK
			break

func turn_on_live_lights():
	var index = 0
	for light in lives_light_container.get_children():
		index += 1
		if index <= VHS_DATA.number_of_failures_before_break:
			light.color = Color.GREEN
