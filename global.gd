extends Node

var is_new_game: bool = true
var is_dialogue_open: bool = false

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
