extends Node

signal add_log_line(msg: String, color: Color)

var is_new_game: bool = true
var no_computer: bool = false
var is_clocking_in: bool = true
var is_dialogue_open: bool = false
var player_movement_disabled: bool = false
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
