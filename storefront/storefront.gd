extends Node2D

@onready var backroom_label = $Backroomdoor/BackroomLabel

func _ready() -> void:
	if g.is_new_game:
		g.is_dialogue_open = true
		$FadeBlack.color = Color.BLACK
		$FadeBlack.show()
		var tween = get_tree().create_tween()
		tween.tween_interval(1.5)
		tween.tween_callback(a.play_random_sfx.bind('storefront_door_entry'))
		tween.tween_property($FadeBlack, 'modulate:a', 0.5, 2)
		tween.tween_callback($Dialogue.set_player_message.bind('There’s no movies here! I better start rewinding to fill this place back up!'))
		tween.tween_property($FadeBlack, 'modulate:a', 0.0, 2)
		tween.tween_callback($FadeBlack.hide)
		g.is_new_game = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and backroom_label.visible:
		get_tree().change_scene_to_file("res://backroom/backroom.tscn")


func _on_back_room_door_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.show()


func _on_back_room_door_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.hide()
