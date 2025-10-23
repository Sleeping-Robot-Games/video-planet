extends Node

var music_db_override_values = {
	#'title': 0,
}

var sfx_db_override_values = {
	#'title': 0,
}

var sfx_pitch_override_values = {
	#'title': {
		#'pitch_range': 0,
		#'base_pitch': 0
	#},
}


# Tracks that don't need a position
var non_positional_tracks = [
	
]

func is_track_centered(track_name):
	return track_name in non_positional_tracks

func get_pitch(pitch_range, base_pitch):
	randomize()
	var final_pitch = randf() * pitch_range + base_pitch
	return final_pitch

func play_music(track_name, overrides = {}):
	var music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
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
		
	music_player.stream = load("res://sounds/music/"+track_name+'.ogg')
	add_child(music_player) # adds the music to the root of the game
	music_player.play()
	
	# Returns a reference to the music player node for signals
	return music_player


func stop_playing_music(track_name):
	var music_player = get_node_or_null(track_name)
	if music_player:
		music_player.queue_free()
	

func play_random_sfx(parent, track_name, overrides = {}):
	var sfx_player = AudioStreamPlayer2D.new()
	sfx_player.bus = "SFX"
	
	# Position override
	if overrides.has('position') and overrides.position:
		sfx_player.position = overrides.position
		
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
			
	var tracks = g.files_in_dir('res://sounds/sfx/', track_name)
	if tracks.size() > 0:
		randomize()
		var random_track = tracks.pick_random()
		sfx_player.stream = load('res://sounds/sfx/' + random_track)
		#sfx_player.connect("finished", sfx_player, "queue_free")
		parent.add_child(sfx_player)
		sfx_player.play()
	
	# Returns a reference to the music player node for signals
	return sfx_player


func play_sfx(parent, track_name,  overrides = {}):
	var sfx_player = AudioStreamPlayer2D.new()
	sfx_player.bus = "SFX"
	
	# Position override
	if overrides.has('position'):
		sfx_player.position = overrides.position
	elif is_track_centered(track_name):
		sfx_player.position = Vector2(320, 180)
	
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
	var track_path = 'res://sounds/sfx/'+track_name+'.ogg'
	if ResourceLoader.exists(track_path):
		sfx_player.stream = load(track_path)
		#sfx_player.connect("finished", sfx_player, "queue_free")
		parent.call_deferred('add_child', sfx_player)
		sfx_player.play()
	
	# Returns a reference to the music player node for signals
	return sfx_player
	
