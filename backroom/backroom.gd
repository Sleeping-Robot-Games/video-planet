extends Node2D

## Minigame Balance Variables - Tweak these to adjust difficulty!
@export_group("Success Requirements")
@export var min_successes_required := 2
@export var max_successes_required := 4

@export_group("Failure Settings")
@export var min_failures_before_break := 2
@export var max_failures_before_break := 5
@export var failure_weight_options: Array[int] = [3, 4, 5, 5, 4, 3, 2, 1]  # Weighted pool

@export_group("Hitzone Settings")
@export var hitzone_position_min := 0.2
@export var hitzone_position_max := 0.6

@export_group("Dial Zone Settings")
@export var dial_tight_center_min := -80.0
@export var dial_tight_center_max := 80.0
@export var dial_tight_half_min := 5.0
@export var dial_tight_half_max := 12.0
@export var dial_rough_additional_min := 15.0
@export var dial_rough_additional_max := 25.0

@export_group("Tick Speed Settings")
@export var base_tick_speed := 1.0  ## Starting ticker movement speed
@export var tick_speed_increase_per_hit := 0.2  ## Amount to increase speed after each successful hit
@export var max_tick_speed := 3.0  ## Maximum ticker speed cap

@export_group("Hit Quality Thresholds")
@export_range(0.0, 1.0) var perfect_hit_threshold := 0.2  ## % of hitzone width for PERFECT
@export_range(0.0, 1.0) var good_hit_threshold := 0.5     ## % of hitzone width for GOOD
@export_range(0.0, 1.0) var ok_hit_threshold := 1.0       ## % of hitzone width for OK

@export_group("Tracking Button Cooldown")
@export var tracking_button_cooldown_time := 1.0  ## Time in seconds before tracking buttons can be pressed again
@export var initial_tracking_cooldown := true      ## If true, buttons start on cooldown; if false, first press has no cooldown

@export_group("Dial Speed Settings")
@export var dial_speed_initial := 80.0      ## Starting rotation speed in degrees/second
@export var dial_speed_max := 200.0         ## Maximum rotation speed in degrees/second
@export var dial_acceleration_time := 0.67  ## Time in seconds to reach max speed

@export_group("Hit Quality Floating Text")
@export var hit_text_float_distance := 40.0  ## How far the text floats upward
@export var hit_text_duration := 1.0  ## Duration of the floating animation
@export var hit_text_scale_mult := 1.2  ## Scale multiplier for text emphasis

@onready var vcr = $VCR
@onready var vcr_sprite = $VCR/Sprite2D
@onready var tracking = $VCR/Tracking
@onready var tick = $VCR/Ticker/Path2D/TickPathFollow2D/Tick
@onready var tick_path_follow = $VCR/Ticker/Path2D/TickPathFollow2D
@onready var hitzone_path_follow = $VCR/Ticker/Path2D/HitzonePathFollow2D
@onready var hitzone = $VCR/Ticker/Path2D/HitzonePathFollow2D/HitZone
@onready var hit_quality_label = $VCR/Ticker/Path2D/HitzonePathFollow2D/HitZone/HitQualityLabel
@onready var dial = $VCR/Dial
@onready var dial_light = $VCR/DialLight
@onready var rewind_button = $VCR/RewindButton
@onready var left_spool = $VCR/SpoolIndicator
@onready var right_spool = $VCR/SpoolIndicator2
@onready var vcr_anim_player = $VCR/AnimationPlayer
@onready var tree_anim_player = $AnimationPlayer
@onready var fix_tape_button = $FixTapeButton
@onready var rewind_effect: ColorRect = $SubViewportContainer/SubViewport/RewindEffectRect
@onready var tv_off_screen = $SubViewportContainer/SubViewport/TVOff
@onready var video_player = $SubViewportContainer/SubViewport/VideoStreamPlayer
@onready var lives_light_container = $VCR/LivesLightContainer
@onready var track_button_cooldown_timer = $TrackButtonCooldownTimer
@onready var tracking_cooldown_lights = $VCR/TrackingCooldownLights

const DIAL_ROTATE_MIN = -100.0
const DIAL_ROTATE_MAX = 100.0

var rewinding_movie_id: String = ''

var music_player: AudioStreamPlayer
var rewind_audio_player: AudioStreamPlayer2D
var static_audio_player: AudioStreamPlayer2D

var dial_angle = 0.0
var dial_current_speed = 0.0  # Current rotation speed with acceleration

var tracking_input_map = {
	"1": null,
	"2": null,
	"3": null,
	"4": null,
}

var tick_speed = 0
var tick_direction := 1.0 # 1 = forward, -1 = backward

# how wide the hitzone is based on the track setting weight
var hitzone_scale_lookup = {
	2: .35,
	1: .9,
	0: 1.5,
}

var current_ideal_track_setting
var current_toggled_track_setting

var num_of_misses = 0

var rewinding = false
var successful_hits = 0
var tape_broken = false
var tape_fixed = false
var tracking_buttons_on_cooldown = false
var first_tracking_press = true  # Track if this is the first button press

var VHS_DATA = {}


func _ready():
	g.no_computer = false
	randomize()
	tree_anim_player.play("trees")
	var bgm_pool = ['backroom_bgm_1', 'backroom_bgm_2', 'backroom_bgm_3', 'backroom_bgm_5_loop']
	music_player = a.play_music(bgm_pool.pick_random())
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	$Website.rewind_movie_selected.connect(_on_website_rewind_movie_selected)
	for tracking_button in tracking.get_children():
		tracking_button.pressed.connect(_on_tracking_button_pressed.bind(tracking_button.name))
		tracking_input_map[tracking_button.name] = tracking_button
	_connect_ui_buttons()
	
func _connect_ui_buttons():
	for button in get_tree().get_nodes_in_group("ui_buttons"):
		button.mouse_entered.connect(func():
			a.play_sfx("menu_select"))
		button.pressed.connect(func():
			a.play_sfx("menu_confirm"))

func _unhandled_input(event: InputEvent):
	if not rewinding:
		if event.is_action_pressed('fix'):
			fix_tape_button.pressed.emit()
		if event.is_action_pressed('rewind'):
			$BacklogButton.pressed.emit()
		return

	for key in tracking_input_map.keys():
		if event.is_action_pressed(key):
			if not tracking_buttons_on_cooldown:
				tracking_input_map[key].button_pressed = true
				tracking_input_map[key].pressed.emit()
			
	if event.is_action_pressed('hit'):
		# Check if hitbox is enabled before allowing hit attempt
		if VHS_DATA.has(1):
			var dial_zone = VHS_DATA[1].dial_zone
			var in_green_zone = dial.rotation_degrees >= dial_zone.tight_zone[0] and dial.rotation_degrees <= dial_zone.tight_zone[1]
			var in_yellow_zone = dial.rotation_degrees >= dial_zone.rough_zone[0] and dial.rotation_degrees <= dial_zone.rough_zone[1]
			if not in_green_zone and not in_yellow_zone:
				return  # Don't process hit when hitbox disabled

		var hit_quality = check_hit_accuracy()

		# Show floating text with hit quality
		show_hit_quality_text(hit_quality)

		# Debug: Print hit quality and distance
		var tick_pos = tick_path_follow.progress_ratio
		var hitzone_pos = hitzone_path_follow.progress_ratio
		var distance = abs(tick_pos - hitzone_pos)
		print("Hit attempt: Quality=%s | Distance=%.4f | Tick=%.4f | Hitzone=%.4f" % [hit_quality, distance, tick_pos, hitzone_pos])

		if hit_quality != "MISS":
			# Successful hit - ticker continues moving
			successful_hits += 1
			if successful_hits >= VHS_DATA[1].success_count_to_continue:
				complete_tape_rewind()
			on_success()
		else:
			on_miss()

func update_tick_movement(delta: float) -> void:
	"""Updates the ticker position and handles direction changes at boundaries"""
	tick_path_follow.progress_ratio += tick_speed * delta * tick_direction

	if tick_path_follow.progress_ratio >= 1.0:
		tick_path_follow.progress_ratio = 1.0
		tick_direction = -1.0
		a.play_random_sfx('ticker_wall', tick)
	elif tick_path_follow.progress_ratio <= 0.0:
		tick_path_follow.progress_ratio = 0.0
		tick_direction = 1.0
		a.play_random_sfx('ticker_wall', tick)

func increase_tick_speed() -> void:
	"""Increases tick speed after a successful hit, up to the maximum"""
	tick_speed = min(tick_speed + tick_speed_increase_per_hit, max_tick_speed)
	print("Tick speed increased to: %.2f" % tick_speed)

func reset_tick_speed() -> void:
	"""Resets tick speed to the base value"""
	tick_speed = base_tick_speed

func show_hit_quality_text(quality: String) -> void:
	"""Displays floating text showing hit quality with color-coded feedback"""
	# Create a new label instance for this hit so multiple can exist simultaneously
	var new_label = Label.new()
	new_label.text = quality
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	new_label.z_index = 100

	# Copy font size from the template label
	new_label.add_theme_font_size_override("font_size", 20)

	# Set color based on quality
	match quality:
		"PERFECT":
			new_label.modulate = Color(1.0, 0.84, 0.0)  # Gold
		"GOOD":
			new_label.modulate = Color(0.0, 1.0, 0.5)  # Light Green
		"OK":
			new_label.modulate = Color(1.0, 0.65, 0.0)  # Orange
		"MISS":
			new_label.modulate = Color(1.0, 0.2, 0.2)  # Red

	# Position above hitzone
	var start_pos = Vector2(0, -25)
	new_label.position = start_pos
	new_label.scale = Vector2(1.0, 1.0)

	# Add to hitzone so it moves with it
	hitzone.add_child(new_label)

	# Create independent tween that won't be affected by scene tree pause
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Continue even when scene pauses
	tween.set_parallel(true)

	# Float upward (using export variable)
	tween.tween_property(new_label, "position", start_pos + Vector2(0, -hit_text_float_distance), hit_text_duration)

	# Scale up slightly (using export variable)
	tween.tween_property(new_label, "scale", Vector2(hit_text_scale_mult, hit_text_scale_mult), 0.3)

	# Fade out (using export variable for duration)
	tween.tween_property(new_label, "modulate:a", 0.0, hit_text_duration)

	# Remove label when animation completes
	tween.chain().tween_callback(func():
		new_label.queue_free()
	)

func _process(delta):
	$Clouds/ParallaxFast.scroll_offset.x += 6 * delta
	$Clouds/ParallaxSlow.scroll_offset.x += 1.5 * delta
	
	if not rewinding:
		return

	if Input.is_action_pressed('dial_right'):
		# Calculate acceleration rate based on time to reach max speed
		var acceleration = (dial_speed_max - dial_speed_initial) / dial_acceleration_time
		dial_current_speed = min(dial_current_speed + acceleration * delta, dial_speed_max)
		dial_angle += dial_current_speed * delta
	elif Input.is_action_pressed('dial_left'):
		# Calculate acceleration rate based on time to reach max speed
		var acceleration = (dial_speed_max - dial_speed_initial) / dial_acceleration_time
		dial_current_speed = min(dial_current_speed + acceleration * delta, dial_speed_max)
		dial_angle -= dial_current_speed * delta
	else:
		# Reset speed when released
		dial_current_speed = dial_speed_initial

	dial_angle = clamp(dial_angle, DIAL_ROTATE_MIN, DIAL_ROTATE_MAX)
	dial.rotation_degrees = dial_angle

	if not VHS_DATA.has(1):
		return

	var dial_zone = VHS_DATA[1].dial_zone

	if dial.rotation_degrees >= dial_zone.tight_zone[0] and dial.rotation_degrees <= dial_zone.tight_zone[1]:
		# Green zone - hitbox enabled with bonus
		dial_light.color = Color.GREEN
		hitzone.modulate = Color.GREEN
		## TODO: a.play_sfx('dial_light_green', vcr_sprite)
	elif dial.rotation_degrees >= dial_zone.rough_zone[0] and dial.rotation_degrees <= dial_zone.rough_zone[1]:
		# Yellow zone - hitbox enabled normally
		dial_light.color = Color.YELLOW
		hitzone.modulate = Color.YELLOW
	else:
		# No zone - hitbox disabled
		dial_light.color = Color.BLACK
		hitzone.modulate = Color.GRAY

	# Update ticker movement (speed increases with each successful hit)
	update_tick_movement(delta)

func on_success():
	if not rewinding:
		return

	a.play_sfx('tape_scratch_good', vcr_sprite)

	vcr_anim_player.pause()

	var left_spool_rot = left_spool.rotation
	var right_spool_rot = right_spool.rotation

	# Store current hitzone color before flashing
	var current_hitzone_color = hitzone.modulate

	var brightness_tween = create_tween()
	brightness_tween.tween_property(hitzone, "modulate", Color(1.2, 1.2, 1.5), 0.15)
	brightness_tween.tween_property(hitzone, "modulate", current_hitzone_color, 0.15)

	var rotation_tween = create_tween()

	# Both spools spin fast, full rotation in opposite directions
	var full_rot := deg_to_rad(360)
	rotation_tween.tween_property(left_spool, "rotation", left_spool_rot - full_rot, 0.35)
	rotation_tween.parallel().tween_property(right_spool, "rotation", right_spool_rot - full_rot, 0.35)

	var scale_tween = create_tween()
	scale_tween.tween_property(left_spool, "scale", left_spool.scale + Vector2(.2, .2), .35)
	scale_tween.parallel().tween_property(right_spool, "scale", right_spool.scale - Vector2(.2, .2), .35)

	if rewinding:
		# Increase tick speed immediately after successful hit
		increase_tick_speed()

		# Resume main spin animation
		rotation_tween.tween_callback(func():
			vcr_anim_player.play("spin")
		)


func on_miss():
	if not rewinding:
		return
		
	a.play_sfx('tape_scratch_bad', vcr_sprite)
		
	num_of_misses += 1
	
	vcr_anim_player.pause()

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
		a.play_sfx('rewind_break', vcr_sprite)
		tape_broken = true
		$VCR/Tape.play_backwards()
		rewinding = false
		if rewind_audio_player:
			rewind_audio_player.stop()
		static_audio_player.stop()
		tv_off_screen.show()
		video_player.paused = true
	else:
		# Resume the spin loop
		rotation_tween.tween_callback(Callable(vcr_anim_player, "play").bind("spin"))


func _on_tracking_button_pressed(track_setting: String):
	if not rewinding:
		return

	# Check if this button is already toggled - keep it pressed, don't allow deselection
	if current_toggled_track_setting == track_setting:
		var button = tracking_input_map[track_setting]
		if button:
			button.button_pressed = true  # Keep it pressed
		return

	if tracking_buttons_on_cooldown:
		# Unpress the button since we're on cooldown
		var button = tracking_input_map[track_setting]
		if button:
			button.button_pressed = false
		return

	a.play_random_sfx('botton_press', tracking)

	# Start cooldown (skip if this is the first press and initial cooldown is disabled)
	if initial_tracking_cooldown or not first_tracking_press:
		tracking_buttons_on_cooldown = true
		track_button_cooldown_timer.start(tracking_button_cooldown_time)
		animate_cooldown_lights()

	first_tracking_press = false  # Mark that first press has occurred

	current_toggled_track_setting = track_setting
	var current_tracking_setting_weight = VHS_DATA[1].track_setting_weights[current_toggled_track_setting]
	var new_scale = Vector2(hitzone_scale_lookup[current_tracking_setting_weight], 2)
	var hitzone_tween = create_tween()
	hitzone_tween.tween_property(hitzone, 'scale', new_scale, .5)

	update_rewind_noise_by_tracking_setting()


func update_rewind_noise_by_tracking_setting():
	var current_tracking_setting_weight = VHS_DATA[1].track_setting_weights[current_toggled_track_setting]

	var chosen = int(current_tracking_setting_weight)

	var noise_value := 0.2 # Default
	match chosen:
		0:
			noise_value = 0.2
			static_audio_player.volume_db = a.static_sfx_levels['quiet']
		1:
			noise_value = 0.06
			static_audio_player.volume_db = a.static_sfx_levels['medium']
		2:
			noise_value = 0.02
			static_audio_player.volume_db = a.static_sfx_levels['loudest']
		_:
			noise_value = 0.02
			static_audio_player.volume_db = a.static_sfx_levels['loudest']
	
	set_rewind_noise(noise_value)

	
## Position-based hit detection - returns hit quality or MISS
func check_hit_accuracy() -> String:
	# Check if hitbox is enabled based on dial position
	if not VHS_DATA.has(1):
		return "MISS"

	var dial_zone = VHS_DATA[1].dial_zone
	var in_green_zone = dial.rotation_degrees >= dial_zone.tight_zone[0] and dial.rotation_degrees <= dial_zone.tight_zone[1]
	var in_yellow_zone = dial.rotation_degrees >= dial_zone.rough_zone[0] and dial.rotation_degrees <= dial_zone.rough_zone[1]

	# Hitbox disabled if not in any zone
	if not in_green_zone and not in_yellow_zone:
		return "MISS"

	var tick_pos = tick_path_follow.progress_ratio
	var hitzone_pos = hitzone_path_follow.progress_ratio
	var distance = abs(tick_pos - hitzone_pos)

	# Get current hitzone scale based on tracking setting (default to middle quality if none selected)
	var tracking_setting = current_toggled_track_setting if current_toggled_track_setting else "1"
	var current_tracking_weight = VHS_DATA[1].track_setting_weights.get(tracking_setting, 1)
	var hitzone_visual_scale = hitzone_scale_lookup[current_tracking_weight]

	# Calculate base hitzone width dynamically from actual path length
	# Assumes hitzone sprite is approximately 22px wide
	var path_length = tick_path_follow.get_parent().curve.get_baked_length()
	var hitzone_sprite_width = 22.0  # Approximate width of hitzone sprite in pixels
	var base_hitzone_width = hitzone_sprite_width / path_length
	var actual_hitzone_width = base_hitzone_width * hitzone_visual_scale

	# Check against absolute distance thresholds
	var hit_result = "MISS"
	if distance < actual_hitzone_width * perfect_hit_threshold:
		hit_result = "PERFECT"
	elif distance < actual_hitzone_width * good_hit_threshold:
		hit_result = "GOOD"
	elif distance < actual_hitzone_width * ok_hit_threshold:
		hit_result = "OK"

	# If in green zone and hit was successful, print bonus message
	if in_green_zone and hit_result != "MISS":
		print("BONUS HIT! Green zone multiplier active")

	return hit_result

func init_vhs():
	$VCR/Labels.show()
	VHS_DATA = generate_vhs_data()
	hitzone_path_follow.progress_ratio = VHS_DATA[1].hitzone_position
	current_ideal_track_setting = get_best_track_setting()
	rewinding = true
	vcr_anim_player.play('spin')
	tv_off_screen.hide()
	set_rewind_noise()
	turn_on_live_lights()

	# Start the tracking button cooldown (if initial cooldown is enabled)
	first_tracking_press = true
	if initial_tracking_cooldown:
		tracking_buttons_on_cooldown = true
		track_button_cooldown_timer.start(tracking_button_cooldown_time)
		animate_cooldown_lights()
	else:
		# Start with all lights green (ready to press)
		tracking_buttons_on_cooldown = false
		for light in tracking_cooldown_lights.get_children():
			light.color = Color.GREEN

	## play video based on genre
	video_player.stream = load(get_video_file_by_genre())
	video_player.play()

	# Start with middle quality scale (weight 1 = 0.9) to match default detection
	var hitzone_scale_tween = create_tween()
	hitzone_scale_tween.tween_property(hitzone, 'scale', Vector2(hitzone_scale_lookup[1], 2), 1)

	# Initialize hitbox as disabled (gray) until dial is positioned
	hitzone.modulate = Color.GRAY

	# Initialize tick speed (increases with successful hits)
	reset_tick_speed()

	play_vhs_audio()

func play_vhs_audio():
	# Play startup
	var startup_player = a.play_sfx('vhs_startup', vcr_sprite)
	static_audio_player = a.play_sfx('static', vcr_sprite)
	
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
	tape_fixed = false
	fix_tape_button.hide()
	rewinding = true
	reset_tick_speed()  # Reset tick speed when restarting after fix
	$VCR/AnimationPlayer.play('spin')
	tv_off_screen.hide()
	video_player.paused = false
	video_player.play()
	set_rewind_noise()
	turn_on_live_lights()
	rewind_audio_player.play()
	static_audio_player.play()

	# Start the tracking button cooldown (if initial cooldown is enabled)
	first_tracking_press = true
	if initial_tracking_cooldown:
		tracking_buttons_on_cooldown = true
		track_button_cooldown_timer.start(tracking_button_cooldown_time)
		animate_cooldown_lights()
	else:
		# Start with all lights green (ready to press)
		tracking_buttons_on_cooldown = false
		for light in tracking_cooldown_lights.get_children():
			light.color = Color.GREEN


func complete_tape_rewind():
	## Success! Tape rewind complete
	successful_hits = 0
	a.play_sfx('rewind_complete', vcr_sprite)
	a.play_sfx('putting_tape_in', vcr_sprite, {'db': 15})
	a.play_sfx('rental_return_no_review')
	## Player can now select a new tape from the backlog or leave back to the store front
	rewinding = false
	rewind_audio_player.stop()
	static_audio_player.stop()
	m.inventory[rewinding_movie_id].status = 'STOCKED'
	m.inventory[rewinding_movie_id].location = 'ON SHELF'
	var log_msg: String = '%s rewound & stocked!' % m.inventory[rewinding_movie_id].title
	g.add_log_line.emit(log_msg, 'SUCCESS')
	$VCR/AnimationPlayer.pause()
	$VCR/Labels.hide()
	video_player.stop()
	tv_off_screen.show()
	for tracking_btn in tracking.get_children():
		tracking_btn.button_pressed = false

	left_spool.scale = Vector2(.4, .4)
	right_spool.scale = Vector2(2, 2)

	$BacklogButton.show()
	$StorefrontButton.show()
	$VCR/Labels.hide()
	reset_cooldown_lights()
		

func _on_website_rewind_movie_selected(movie_id: String) -> void:
	rewinding_movie_id = movie_id
	$VCR/Labels/RewindingMovieLabel.text = 'Rewinding %s' % m.inventory[movie_id].title
	$VCR/Labels.show()
	$BacklogButton.hide()
	$StorefrontButton.hide()
	$VCR/Tape.play()
	a.play_sfx('putting_tape_in', vcr_sprite)
	

func get_best_track_setting() -> String:
	var track_weights = VHS_DATA[1].track_setting_weights

	for track_number in track_weights.keys():
		if track_weights[track_number] == 0:
			return track_number

	# fallback if no weight 0 found
	push_error("No weight 0 found in track settings")
	return ""


func _on_fix_tape_button_pressed() -> void:
	if tape_fixed:
		return
	tape_fixed = true
	tape_broken = false
	a.play_sfx("tape_fix", vcr_sprite)
	$FixTapeButton.hide()
	
	# Reset progress first
	$FixBar.value = 0
	$FixBar.show()

	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# Fill progress bar over 4 seconds
	tween.tween_property($FixBar, "value", 100.0, 4.0)

	# After tween finishes → hide UI & play tape
	tween.tween_callback(func():
		$FixBar.hide()
		$VCR/Tape.play()
		a.play_sfx('putting_tape_in', vcr_sprite)
	)


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
	music_player.stop()
	music_player.queue_free()
	get_tree().change_scene_to_file('res://storefront/storefront.tscn')


func generate_vhs_data() -> Dictionary:
	var data := {}

	# 1) Number of failures before break (uses export variables)
	if failure_weight_options.size() > 0:
		data["number_of_failures_before_break"] = failure_weight_options[randi() % failure_weight_options.size()]
	else:
		# Fallback if array is empty
		data["number_of_failures_before_break"] = randi_range(min_failures_before_break, max_failures_before_break)

	# 2) Generate VHS rewind difficulty with configurable successes required
	var success_required := randi_range(min_successes_required, max_successes_required)

	var used_zero_index := randi() % 4  # Random index 0-3 for best track
	var hitzone_position = randf_range(hitzone_position_min, hitzone_position_max)

	# --- Track Setting Weights ---
	var track_weights := {}
	for i in range(4):
		var weight_index := (i - used_zero_index) % 4
		var weight := 2  # default worst
		if abs(weight_index) <= 1:
			weight = 1 # middle quality
		if weight_index == 0:
			weight = 0 # BEST setting

		track_weights[str(i + 1)] = weight

	# --- Dial Zones (uses export variables) ---
	var tight_center = randf_range(dial_tight_center_min, dial_tight_center_max)
	var tight_half = randf_range(dial_tight_half_min, dial_tight_half_max)
	var rough_half = tight_half + randf_range(dial_rough_additional_min, dial_rough_additional_max)

	var dial_zone := {
		"tight_zone": [tight_center - tight_half, tight_center + tight_half],
		"rough_zone": [tight_center - rough_half, tight_center + rough_half],
	}

	# Assign tape difficulty data
	data[1] = {
		"track_setting_weights": track_weights,
		"dial_zone": dial_zone,
		"hitzone_position": hitzone_position,
		"success_count_to_continue": success_required,
	}

	return data


func _on_tape_animation_finished() -> void:
	if tape_broken:
		fix_tape_button.show()
	elif tape_fixed:
		start_vhs_rewind_after_fix()
	else:
		init_vhs()


func _on_track_button_cooldown_timer_timeout() -> void:
	tracking_buttons_on_cooldown = false


func animate_cooldown_lights():
	# Get all light children - they're in VBoxContainer so index 0 is top, last is bottom
	var lights = tracking_cooldown_lights.get_children()

	# Turn all lights black first
	for light in lights:
		light.color = Color.BLACK

	# Calculate delay between each light based on cooldown time
	var delay_per_light = tracking_button_cooldown_time / lights.size()

	# Create tween to light up each LED from bottom to top
	# We need to start from the last index (bottom) and go to 0 (top)
	for i in range(lights.size()):
		var light_index = lights.size() - 1 - i  # Reverse the index to go bottom to top
		var light = lights[light_index]

		# Schedule this light to turn on at the appropriate time
		get_tree().create_timer(delay_per_light * i).timeout.connect(func():
			if light:  # Check if light still exists
				var tween = create_tween()
				tween.tween_property(light, "color", Color.GREEN, 0.05)
		)


func reset_cooldown_lights():
	# Turn all lights black
	for light in tracking_cooldown_lights.get_children():
		light.color = Color.BLACK
