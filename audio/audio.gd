extends Node

var music_db_override_values = {
	#'track.ogg': 0,
	'backroom_bgm_1': -10,
	'backroom_bgm_2': -10,
	'backroom_bgm_3': -10,
	'storefront_bgm_1': -10,
	'titlescreen_bgm_1': -10
}

var static_sfx_levels = {
	'loudest': -10,
	'medium': -15,
	'quiet': -20
}

var sfx_db_override_values = {
	#'track.wav': 0,
	'botton_press': 8,
	'crickets': 0,
	'footstep_carpet': -15,
	'footstep_tile': -15,
	'menu_confirm': -20,
	'menu_select': -20,
	'pc_login': -20.,
	'pc_logoff': -20,
	'place_item': -5,
	'putting_tape_in': 0,
	'rain': 0,
	'rental_return_bad_review': 0,
	'rental_return_good_review': 0,
	'rental_return_no_review': 0,
	'rewind_complete': 13,
	'rewind_break': -10,
	'service_bell': 0,
	'static': static_sfx_levels['loudest'],
	'storefront_door_entry': -2,
	'storefront_door_exit': -2,
	'tape_scratch_bad': 0,
	'tape_scratch_good': -4,
	'vhs_rewind': -5,
	'vhs_startup': 15
}


var sfx_pitch_override_values = {
	#'track.wav': {
		#'pitch_range': 0,
		#'base_pitch': 0
	#},
}

# SFX Bus declarations not needed, as the default Audio Bus to SFX
var sfx_bus_lookup = {
	#'track.wav': 'UI'
	'menu_confirm': 'UI',
	'menu_select': 'UI',
	'crickets': 'Ambience',
	'rain': 'Ambience',
	'static': 'Ambience',
	'vhs_rewind': 'Ambience'
	
}

# Tracks that don't need a position
var non_positional_tracks = [
	'menu_select',
	'menu_confirm',
	'pc_login',
	'pc_logoff'
]

func _ready():
	call_deferred('_connect_ui_buttons')

## Remember this for future projects, this is dope
func _connect_ui_buttons():
	for button in get_tree().get_nodes_in_group("ui_buttons"):
		if button is Button:
			button.mouse_entered.connect(func():
				a.play_sfx("menu_select"))
			button.pressed.connect(func():
				a.play_sfx("menu_confirm"))

func is_track_non_positional(track_name):
	return track_name in non_positional_tracks

func get_pitch(pitch_range, base_pitch):
	randomize()
	var final_pitch = randf() * pitch_range + base_pitch
	return final_pitch

func play_music(track_name, overrides = {}):
	var music_player = AudioStreamPlayer.new()
	music_player.bus = "BGM"
	music_player.name = track_name
		
	# Volume override
	if overrides.has('db') and overrides.db: # Override option for some specific event in game that different from the standard
		music_player.volume_db = overrides.db
	else: # Standard override mix for the track type
		if track_name in music_db_override_values:
			music_player.volume_db = music_db_override_values[track_name]
		else:
			print("No standard db override mix for track ", track_name)
			
	# Pitch override	
	if overrides.has('pitch') and overrides.pitch:
		music_player.pitch_scale = overrides.pitch
	else:
		music_player.pitch_scale = 1.0  # Default pitch
		
	music_player.stream = load("res://audio/music/"+track_name+".ogg")
	add_child(music_player) # adds the music to the root of the game
	music_player.play()
	
	# Returns a reference to the music player node for signals
	return music_player


func stop_playing_music(track_name):
	var music_player = get_node_or_null(track_name)
	if music_player:
		music_player.queue_free()

func create_sfx_player(track_name):
	var sfx_player
	if is_track_non_positional(track_name):
		sfx_player =  AudioStreamPlayer.new()
	else:
		sfx_player = AudioStreamPlayer2D.new()
		
	if sfx_bus_lookup.has(track_name):
		sfx_player.bus = sfx_bus_lookup[track_name]
	else:
		sfx_player.bus = 'SFX'
	return sfx_player

func play_random_sfx(track_name, parent = self, overrides = {}):
	var tracks = g.files_in_dir('res://audio/sfx/', track_name)
	var random_track = null
	if tracks.size() > 0:
		randomize()
		random_track = tracks.pick_random()
	
	if not random_track:
		print('WARNING: play_random_sfx() failed to resolve random track for ', track_name)
		return
	
	var sfx_player = create_sfx_player(random_track)
	
	# Position override
	if overrides.has('position') and overrides.position:
		sfx_player.position = overrides.position
	
	# Seek override
	if overrides.has('seek_to') and overrides.seek_to:
		sfx_player.seek(overrides.seek_to)
	
	# Volume override
	if overrides.has('db') and overrides.db: # Override option for some specific event in game that different from the standard
		sfx_player.volume_db = overrides.db
	else: # Standard override mix for the track type in the sfx_db_override_values list
		if track_name in sfx_db_override_values:
			sfx_player.volume_db = sfx_db_override_values[track_name]
		else:
			push_warning("No standard db override mix for track ", track_name)
			
	# Pitch override
	if overrides.has('pitch') and overrides.pitch:
		sfx_player.pitch_scale = overrides.pitch
	else:
		if track_name in sfx_pitch_override_values:
			var pitch_range = sfx_pitch_override_values[track_name]['pitch_range']
			var base_pitch = sfx_pitch_override_values[track_name]['base_pitch']
			sfx_player.pitch_scale = get_pitch(pitch_range, base_pitch)
		else:
			push_warning("No standard pitch override mix for track ", track_name)
	
	# Play random track
	sfx_player.stream = load('res://audio/sfx/' + random_track)
	sfx_player.finished.connect(sfx_player.queue_free)
	parent.add_child(sfx_player)
	sfx_player.play()
	
	# Returns a reference to the music player node for signals
	return sfx_player


func play_sfx(track_name, parent = self,  overrides = {}):
	var sfx_player = create_sfx_player(track_name)
	
	# Position override
	if overrides.has('position'):
		sfx_player.position = overrides.position
	
	# Volume override
	if overrides.has('db') and overrides.db: # Override option for some specific event in game that different from the standard
		sfx_player.volume_db = overrides.db
	else: # Standard override mix for the track type
		if track_name in sfx_db_override_values:
			sfx_player.volume_db = sfx_db_override_values[track_name]
		else:
			push_warning("No standard override mix for track ", track_name)
			
	# Pitch override
	if overrides.has('pitch') and overrides.pitch:
		sfx_player.pitch_scale = overrides.pitch
	else:
		if track_name in sfx_pitch_override_values:
			var pitch_range = sfx_pitch_override_values[track_name]['pitch_range']
			var base_pitch = sfx_pitch_override_values[track_name]['base_pitch']
			sfx_player.pitch_scale = get_pitch(pitch_range, base_pitch)
		else:
			push_warning("No standard pitch override mix for track ", track_name)
	var track_path = 'res://audio/sfx/'+track_name+".wav"
	if ResourceLoader.exists(track_path):
		sfx_player.stream = load(track_path)
		sfx_player.finished.connect(sfx_player.queue_free)
		parent.call_deferred('add_child', sfx_player)
		sfx_player.call_deferred('play')
	
	# Returns a reference to the music player node for signals
	return sfx_player
	
