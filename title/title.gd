extends Node2D

var music_player
var master_bus_idx
var music_bus_idx
var sfx_bus_idx
var ui_bus_idx
var ambience_bus_idx

func _ready():
	master_bus_idx = AudioServer.get_bus_index("Master")
	music_bus_idx = AudioServer.get_bus_index("BGM")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")
	ui_bus_idx = AudioServer.get_bus_index("UI")
	ambience_bus_idx = AudioServer.get_bus_index("Ambience")
	music_player = a.play_music('titlescreen_bgm_1')

func _on_button_pressed() -> void:
	music_player.stop()
	music_player.queue_free()
	get_tree().change_scene_to_file("res://storefront/storefront.tscn")


func _on_master_volume_value_changed(value: float) -> void:
	var mute = value == -20
	AudioServer.set_bus_mute(master_bus_idx, mute)
	AudioServer.set_bus_volume_db(master_bus_idx, value)

func _on_music_volume_value_changed(value: float) -> void:
	var mute = value == -20
	AudioServer.set_bus_mute(music_bus_idx, mute)
	AudioServer.set_bus_volume_db(music_bus_idx, value)
	
func _on_sfx_volume_value_changed(value: float) -> void:
	var mute = value == -20
	AudioServer.set_bus_mute(sfx_bus_idx, mute)
	AudioServer.set_bus_volume_db(sfx_bus_idx, value)


func _on_ambience_volume_value_changed(value: float) -> void:
	var mute = value == -20
	AudioServer.set_bus_mute(ambience_bus_idx, mute)
	AudioServer.set_bus_volume_db(ambience_bus_idx, value)


func _on_ui_volume_value_changed(value: float) -> void:
	var mute = value == -20
	AudioServer.set_bus_mute(ui_bus_idx, mute)
	AudioServer.set_bus_volume_db(ui_bus_idx, value)
