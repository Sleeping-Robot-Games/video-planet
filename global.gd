extends Node

signal add_log_line(msg: String, color: Color)
signal shift_time_updated(in_game_time: String, time_remaining: float)

var is_new_game: bool = true
var no_computer: bool = false
var is_new_game_start: bool = true  # Renamed from is_clocking_in for clarity
var is_dialogue_open: bool = false
var player_movement_disabled: bool = false

# Shift system variables
var current_shift: String = "storefront"  # "storefront" or "backroom"
var shift_time_remaining: float = 300.0  # 5 minutes in seconds
var shift_start_time: int = 8  # 8 AM for first shift, 12 PM for second shift
var is_shift_active: bool = false
var decoration_unlocks: Array = [
	{
		'name': 'rug_a',
		'slot': 'rug',
		'unlocks_at': 0,
		'is_unlocked': true
	},
	{
		'name': 'rug_b',
		'slot': 'rug',
		'unlocks_at': 1,
		'is_unlocked': false
	},
	{
		'name': 'cobwebs',
		'slot': 'ceiling',
		'unlocks_at': 3,
		'is_unlocked': false
	},
	{
		'name': 'string_lights',
		'slot': 'ceiling',
		'unlocks_at': 5,
		'is_unlocked': false
	},
	{
		'name': '???',
		'slot': '???',
		'unlocks_at': 8,
		'is_unlocked': false
	},
	{
		'name': '???',
		'slot': '???',
		'unlocks_at': 12,
		'is_unlocked': false
	},
	{
		'name': '???',
		'slot': '???',
		'unlocks_at': 16,
		'is_unlocked': false
	}
]

func _ready() -> void:
	randomize()

func folders_in_dir(path: String) -> Array:
	var folders = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		while true:
			var folder = dir.get_next()
			if folder == "":
				break
			if not folder.begins_with(".") and dir.current_is_dir():
				folders.append(folder)
		dir.list_dir_end()
	return folders

func files_in_dir(path: String, keyword: String = "") -> Array:
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			if keyword != "" and file.find(keyword) == -1:
				continue
			if not file.begins_with(".") and file.ends_with(".import"): # this is for sprites only
				files.append(file.replace(".import", ""))
			elif file.ends_with(".save") or file.ends_with(".cache"): # inclusion for saves
				files.append(file)
		dir.list_dir_end()
	else:
		push_error('ERROR: failed to open folder '+path+'  RC:'+str(dir))
	return files

# Convert remaining shift time to in-game time string
# 5 minutes real-time = 4 hours in-game (240 minutes)
# Each real second = 0.8 in-game minutes (240 / 300)
func get_in_game_time_string() -> String:
	if not is_shift_active:
		return "SHIFT INACTIVE"

	# Calculate elapsed in-game minutes (each real second = 0.8 in-game minutes)
	var elapsed_real_seconds = 300.0 - shift_time_remaining
	var elapsed_in_game_minutes = elapsed_real_seconds * 0.8

	# Round to nearest 10-minute interval for display
	var rounded_minutes = int(elapsed_in_game_minutes / 10) * 10

	# Calculate current in-game time
	var current_hour = shift_start_time + int(rounded_minutes / 60)
	var current_minute = rounded_minutes % 60

	# Format with AM/PM
	var period = "AM"
	var display_hour = current_hour
	if current_hour >= 12:
		period = "PM"
		if current_hour > 12:
			display_hour = current_hour - 12
	elif current_hour == 0:
		display_hour = 12

	return "%d:%02d %s" % [display_hour, current_minute, period]
