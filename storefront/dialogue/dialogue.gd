extends Panel

@onready var player_msg: Label = $Player/VBoxContainer/Message
@onready var player_continue: RichTextLabel = $Player/VBoxContainer/Continue

func _input(event):
	if event.is_action_pressed('continue') and visible and player_continue.visible:
		perform_bounce()

func set_player_message(msg: String) -> void:
	g.is_dialogue_open = true
	player_msg.text = msg
	$Player.show()
	show()

func space_down() -> void:
	player_continue.text = '[center]Press [img=60x30]res://storefront/dialogue/kb_space_down.png[/img] to continue[/center]'

func space_up() -> void:
	player_continue.text = '[center]Press [img=60x30]res://storefront/dialogue/kb_space_up.png[/img] to continue[/center]'

func perform_bounce() -> void:
	var original_position = global_position
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_callback(space_down)
	tween.tween_property(self, 'global_position', original_position - Vector2(0, 5), 0.1)
	tween.chain().tween_property(self, 'global_position', original_position, 0.1)
	tween.chain().tween_callback(space_up)
	tween.chain().tween_interval(0.1)
	tween.chain().tween_callback(close_dialogue)

func close_dialogue() -> void:
	hide()
	g.is_dialogue_open = false
