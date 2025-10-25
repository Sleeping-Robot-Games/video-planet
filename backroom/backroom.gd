extends Node2D

@onready var vcr = $VCR
@onready var vcr_sprite = $VCR/Sprite2D
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

var rewinding_movie_id: String = ''

var music_player: AudioStreamPlayer
var rewind_audio_player: AudioStreamPlayer2D

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

var VHS_DATA = {}


func _ready():
	music_player = a.play_music('backroom_bmg_1')
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	$Website.rewind_movie_selected.connect(_on_website_rewind_movie_selected)
	for tracking_button in tracking.get_children():
		tracking_button.pressed.connect(_on_tracking_button_pressed.bind(tracking_button.name))
		tracking_input_map[tracking_button.name] = tracking_button

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed('fix'):
		fix_tape_button.pressed.emit()

		
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
	
	if not VHS_DATA.has(vhs_phase):
		return
	
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

	a.play_sfx('tape_scratch_good', vcr_sprite)
		
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
		
	a.play_sfx('tape_scratch_bad', vcr_sprite)
		
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
		rewind_audio_player.stop()
		tv_off_screen.show()
		video_player.paused = true
	else:
		# Resume the spin loop
		rotation_tween.tween_callback(Callable(anim_player, "play").bind("spin"))


func _on_tracking_button_pressed(track_setting: String):
	if not rewinding:
		return
		
	a.play_random_sfx('botton_press', tracking)
		
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
	VHS_DATA = generate_vhs_data()
	vhs_phase = 1
	hitzone_path_follow.progress_ratio = VHS_DATA[vhs_phase].hitzone_position
	current_ideal_track_setting = get_best_track_setting_for_phase(vhs_phase)
	rewinding = true
	anim_player.play('spin')
	tv_off_screen.hide()
	set_rewind_noise()
	turn_on_live_lights()
	
	## play video based on genre
	video_player.stream = load(get_video_file_by_genre())
	video_player.play()
	
	var hitzone_scale_tween = create_tween()
	hitzone_scale_tween.tween_property(hitzone, 'scale', Vector2(hitzone_scale_lookup[2], .328), 1)
	
	var tick_speed_tween = create_tween()
	tick_speed_tween.tween_property(self, 'tick_speed', VHS_DATA[vhs_phase].tick_speeds['no_zone'], 1)
	
	play_vhs_audio()

func play_vhs_audio():
	# Play startup
	var startup_player = a.play_sfx('vhs_startup', vcr_sprite)

	# Chain rewind when finished
	if startup_player:
		startup_player.finished.connect(func():
			rewind_audio_player = a.play_sfx('vhs_rewind', vcr_sprite))

func get_video_file_by_genre() -> String:
	var video_genre = m.inventory[rewinding_movie_id].genre
	randomize()
	match video_genre:
		'HORROR':
			return ["res://backroom/snapback_rewind.ogv", "res://backroom/hatchlingheroes_rewind.ogv"].pick_random()
		'SCI-FI':
			return "res://backroom/apotheosis_rewind.ogv"
		'ROMANCE':
			return "res://backroom/tophat_rewind.ogv"
		'COMEDY':
			return ["res://backroom/smokinpotions_rewind.ogv", "res://backroom/cats2up_rewind.ogv"].pick_random()
		_:
			return ["res://backroom/cats2up_rewind.ogv", "res://backroom/hatchlingheroes_rewind.ogv", "res://backroom/apotheosis_rewind.ogv", "res://backroom/smokinpotions_rewind.ogv", "res://backroom/snapback_rewind.ogv", "res://backroom/tophat_rewind.ogv"].pick_random()
	
func start_vhs_rewind_after_fix():
	num_of_misses = 0
	broken_tape.hide()
	broken_tape.rotation_degrees = -180
	broken_tape.modulate = Color.RED
	fix_tape_button.hide()
	rewinding = true
	$VCR/AnimationPlayer.play('spin')
	tv_off_screen.hide()
	video_player.paused = false
	video_player.play()
	set_rewind_noise()
	turn_on_live_lights()
	rewind_audio_player.play()


func next_vhs_phase():
	successful_hits = 0
	vhs_phase += 1
	if not VHS_DATA.has(vhs_phase):
		rewinding = false
		rewind_audio_player.stop()
		## Success!
		## Player can now select a new tape from the backlog or leave back to the store front
		m.inventory[rewinding_movie_id].status = 'STOCKED'
		m.inventory[rewinding_movie_id].location = 'ON SHELF'
		var log_msg: String = '%s rewound & stocked!' % m.inventory[rewinding_movie_id].title
		g.add_log_line.emit(log_msg, 'SUCCESS')
		$VCR/AnimationPlayer.pause()
		video_player.stop()
		tv_off_screen.show()
		for tracking_btn in tracking.get_children():
			tracking_btn.button_pressed = false
			
		left_spool.scale = Vector2(.4, .4)
		right_spool.scale = Vector2(2, 2)
		
		$BacklogButton.show()
		$StorefrontButton.show()
		$VCR/Labels.hide()
	else:
		hitzone_path_follow.progress_ratio = VHS_DATA[vhs_phase].hitzone_position
		current_ideal_track_setting = get_best_track_setting_for_phase(vhs_phase)
		
		update_rewind_noise_by_tracking_setting()
		
		var hitzone_scale_tween = create_tween()
		hitzone_scale_tween.tween_property(hitzone, 'scale', Vector2(hitzone_scale_lookup[VHS_DATA[vhs_phase].track_setting_weights[current_toggled_track_setting]], .328), 1)
		
		var tick_speed_tween = create_tween()
		tick_speed_tween.tween_property(self, 'tick_speed', VHS_DATA[vhs_phase].tick_speeds['no_zone'], 1)
		

func _on_website_rewind_movie_selected(movie_id: String) -> void:
	rewinding_movie_id = movie_id
	$VCR/Labels/RewindingMovieLabel.text = 'Rewinding ’%s’' % m.inventory[movie_id].title
	$VCR/Labels.show()
	$BacklogButton.hide()
	$StorefrontButton.hide()
	init_vhs()
	

func _on_rewind_button_pressed() -> void:
	if rewinding or not rewinding_movie_id:
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
	# Reset all lights first
	for light in lives_light_container.get_children():
		light.color = Color.BLACK
	
	# Turn on correct number of lives
	var failures = VHS_DATA.number_of_failures_before_break
	for i in range(failures):
		lives_light_container.get_child(i).color = Color.GREEN
	
	# Reset miss counter for new tape
	num_of_misses = 0


func _on_backlog_button_pressed() -> void:
	$Website.open_by_backroom_computer()

func _on_storefront_button_pressed() -> void:
	get_tree().change_scene_to_file('res://storefront/storefront.tscn')


func generate_vhs_data() -> Dictionary:
	var data := {}
	
	# 1) Number of failures before break (weighted toward 3-5)
	var failure_options = [3,4,5,5,4,3,2,1] # Weighted list
	data["number_of_failures_before_break"] = failure_options[randi() % failure_options.size()]
	
	# 2) Generate 3 VHS Rewind Phases
	var total_success_required := 8
	var remaining := total_success_required
	var num_phases := 3
	
	var used_zero_index := randi() % 5  # Random index 0-4 for best track each phase
	var hitzone_positions = [.2, .4, .6] # Shuffle for variety
	hitzone_positions.shuffle()

	for phase in range(1, num_phases + 1):
		var is_last_phase = (phase == num_phases)

		# --- Success Count Distribution ---
		var phase_success = 0
		if is_last_phase:
			phase_success = remaining
		else:
			# Give between 2-4 successes early, but leave enough for end
			phase_success = clamp(randi() % 3 + 2, 1, remaining - (num_phases - phase))
		remaining -= phase_success

		# --- Track Setting Weights ---
		var track_weights := {}
		for i in range(5):
			var weight_index := (i - used_zero_index) % 5
			var weight := 2  # default worst
			if abs(weight_index) <= 1:
				weight = 1 # middle quality
			if weight_index == 0:
				weight = 0 # BEST setting
			
			track_weights[str(i + 1)] = weight

		# Advance pattern shift next phase
		used_zero_index = (used_zero_index + 1) % 5

		# --- Dial Zones ---
		var tight_center = randf_range(-80, 80)
		var tight_half = randf_range(5, 12)
		var rough_half = tight_half + randf_range(15, 25)

		var dial_zone := {
			"tight_zone": [tight_center - tight_half, tight_center + tight_half],
			"rough_zone": [tight_center - rough_half, tight_center + rough_half],
		}

		# --- Tick Speeds ---
		var tick_speeds := {
			"no_zone": randf_range(1.4, 1.9),
			"rough_zone": randf_range(1.1, 1.4),
			"tight_zone": randf_range(0.7, 1.0),
		}

		# Assign phase data
		data[phase] = {
			"track_setting_weights": track_weights,
			"dial_zone": dial_zone,
			"tick_speeds": tick_speeds,
			"hitzone_position": hitzone_positions.pop_front(),
			"success_count_to_continue": phase_success,
		}

	return data
