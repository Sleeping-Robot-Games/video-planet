extends Node2D

@onready var backroom_label: Label = $HUD/BackroomLabel
@onready var todo_panel: Panel = $HUD/ToDo
@onready var fade_black: ColorRect = $HUD/FadeBlack
@onready var shelf_desinations = $ShelfDestinations

var music_player: AudioStreamPlayer

var customer_in_store = false


func _ready() -> void:
	music_player = a.play_music('storefront_bgm_1')
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	init_shelves()
	$Player.position = Vector2(272, 140) if g.is_clocking_in else Vector2(73, 139)
	g.player_movement_disabled = true
	fade_black.color = Color.BLACK
	fade_black.show()
		
	if g.is_new_game:
		var tween = get_tree().create_tween()
		tween.tween_interval(1.5)
		tween.tween_callback(a.play_random_sfx.bind('storefront_door_entry'))
		tween.tween_property(fade_black, 'modulate:a', 0.5, 2)
		tween.tween_callback($HUD/Dialogue.set_player_message.bind('There’s no movies here! I better start rewinding to fill this place back up!'))
		tween.tween_property(fade_black, 'modulate:a', 0.0, 2)
		tween.tween_callback(fade_black.hide)
		tween.tween_callback(unfreeze_player)
		g.is_new_game = false
	else:
		var tween = get_tree().create_tween()
		tween.tween_interval(.75)
		tween.tween_property(fade_black, 'modulate:a', 0.5, 1)
		tween.tween_callback(fade_black.hide)
		tween.tween_callback(unfreeze_player)
	
	g.is_clocking_in = false

func init_shelves() -> void:
	pass

func unfreeze_player() -> void:
	g.player_movement_disabled = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and backroom_label.visible:
		hide_todo()
		music_player.stop()
		music_player.queue_free()
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

func show_backroom_label() -> void:
	$HUD/BackroomEntranceLabel.show()

func hide_backroom_label() -> void:
	$HUD/BackroomEntranceLabel.hide()


func _on_customer_timer_timeout() -> void:
	if not customer_in_store:
		customer_in_store = true
	else:
		return 
		
	var new_customer = c.generate_customer()
	new_customer.store = self
	new_customer.counter = $CounterDestination
	new_customer.exit = $Door
	new_customer.position = $Door.position
	
	
	if new_customer.customer_data.goal == 'return':
		pass # set destinations as counter, then door again
		# TODO: Later
		customer_in_store = false
	else: # renting
		randomize()
		
		var destinations = []
		for _i in randi() % 5: # set customer desintations to random shelves then counter
			destinations.append(shelf_desinations.get_children().pick_random())
		destinations.append($CounterDestination)
		
		add_child(new_customer)
		await get_tree().create_timer(2).timeout
		new_customer.enter_store(destinations)
	
	randomize()
	$CustomerTimer.wait_time = randi() % 30
