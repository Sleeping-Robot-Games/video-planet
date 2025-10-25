extends Node2D

@onready var backroom_label: Label = $Backroomdoor/BackroomLabel
@onready var todo_panel: Panel = $HUD/ToDo

func _ready() -> void:
	$Player.position = Vector2(272, 140) if g.is_clocking_in else Vector2(73, 139)
	print('player position: ', $Player.position)
	g.player_movement_disabled = true
	$FadeBlack.color = Color.BLACK
	$FadeBlack.show()
		
	if g.is_new_game:
		var tween = get_tree().create_tween()
		tween.tween_interval(1.5)
		tween.tween_callback(a.play_random_sfx.bind('storefront_door_entry'))
		tween.tween_property($FadeBlack, 'modulate:a', 0.5, 2)
		tween.tween_callback($Dialogue.set_player_message.bind('There’s no movies here! I better start rewinding to fill this place back up!'))
		tween.tween_property($FadeBlack, 'modulate:a', 0.0, 2)
		tween.tween_callback($FadeBlack.hide)
		tween.tween_callback(unfreeze_player)
		g.is_new_game = false
	else:
		var tween = get_tree().create_tween()
		tween.tween_interval(.75)
		tween.tween_property($FadeBlack, 'modulate:a', 0.5, 1)
		tween.tween_callback($FadeBlack.hide)
		tween.tween_callback(unfreeze_player)
	
	g.is_clocking_in = false

func unfreeze_player() -> void:
	g.player_movement_disabled = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and backroom_label.visible:
		hide_todo()
		get_tree().change_scene_to_file("res://backroom/backroom.tscn")


func _on_back_room_door_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.show()


func _on_back_room_door_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.hide()

func show_todo() -> void:
	todo_panel.show()

func hide_todo() -> void:
	todo_panel.hide()
