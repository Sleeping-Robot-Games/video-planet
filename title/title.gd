extends Node2D

var music_player

func _ready():
	music_player = a.play_music('titlescreen_bgm_1')

func _on_button_pressed() -> void:
	music_player.stop()
	music_player.queue_free()
	get_tree().change_scene_to_file("res://storefront/storefront.tscn")
