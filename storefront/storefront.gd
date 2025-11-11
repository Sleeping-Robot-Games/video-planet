extends Node2D

@onready var backroom_label: Label = $HUD/BackroomLabel
@onready var fade_black: ColorRect = $HUD/FadeBlack
@onready var shelf_desinations = $ShelfDestinations
@onready var dialog = $HUD/Dialogue
@onready var website = $HUD/Website
@onready var shift_clock_label: Label = $HUD/ShiftClockLabel

@warning_ignore("unused_signal")
signal movie_return_to_backlog(movie_id: String, movie_data: Dictionary, customer_name: String)

var music_player: AudioStreamPlayer

var customer_in_store = false

func _ready() -> void:
	var bgm_pool = ['storefront_bgm_1', 'storefront_bgm_2']
	music_player = a.play_music(bgm_pool.pick_random())
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	init_shelves()
	
	$Player.position = Vector2(272, 140) if g.is_new_game_start else Vector2(73, 139)
	# g.player_movement_disabled = true
	fade_black.color = Color.BLACK
	fade_black.show()
	
	if g.is_new_game:
		g.no_computer = true
		var tween = get_tree().create_tween()
		tween.tween_interval(1.5)
		tween.tween_callback(a.play_random_sfx.bind('storefront_door_entry'))
		tween.tween_property(fade_black, 'modulate:a', 0.5, 2)
		tween.tween_callback($HUD/Dialogue.open.bind('There are barely any movies in stock! \n
		I better get to the backroom and \n 
		start rewinding to fill this place back up before we open!'))
		tween.tween_property(fade_black, 'modulate:a', 0.0, 2)
		tween.tween_callback(fade_black.hide)
		tween.tween_callback(unfreeze_player)
		
		show_backroom_label()
		g.is_new_game = false
	else:
		$CustomerTimer.start()
		var tween = get_tree().create_tween()
		tween.tween_interval(.75)
		tween.tween_property(fade_black, 'modulate:a', 0.5, 1)
		tween.tween_callback(fade_black.hide)
		tween.tween_callback(unfreeze_player)
	
	g.is_new_game_start = false
	_connect_ui_buttons()
	update_clock_display()

func _process(delta: float) -> void:
	if g.is_shift_active:
		g.shift_time_remaining -= delta

		# Stop timer at 0, don't go negative
		if g.shift_time_remaining <= 0:
			g.shift_time_remaining = 0
			g.is_shift_active = false

		update_clock_display()

func update_clock_display() -> void:
	shift_clock_label.text = g.get_in_game_time_string()

func _connect_ui_buttons():
	for button in get_tree().get_nodes_in_group("ui_buttons"):
		if button is Button:
			button.mouse_entered.connect(func():
				a.play_sfx("menu_select"))
			button.pressed.connect(func():
				a.play_sfx("menu_confirm"))

func init_shelves() -> void:
	pass

func unfreeze_player() -> void:
	g.player_movement_disabled = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and backroom_label.visible:
		# Check if shift is active - if so, prevent leaving
		if g.is_shift_active:
			backroom_label.text = "Can't leave during shift!"
			await get_tree().create_timer(2).timeout
			backroom_label.text = "PRESS 'E' to Rewind VHS Tapes"
			return

		# Start the backroom shift
		g.is_shift_active = true
		g.current_shift = "backroom"
		g.shift_time_remaining = 300.0  # Reset to 5 minutes

		# Determine shift start time (8 AM for first shift, 12 PM for second)
		# This alternates between shifts
		if g.shift_start_time == 8:
			g.shift_start_time = 12
		else:
			g.shift_start_time = 8

		music_player.stop()
		music_player.queue_free()
		dialog.close()
		get_tree().change_scene_to_file("res://backroom/backroom.tscn")


func _on_back_room_door_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.show()


func _on_back_room_door_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.hide()


func show_backroom_label() -> void:
	$HUD/BackroomEntranceLabel.show()

func hide_backroom_label() -> void:
	$HUD/BackroomEntranceLabel.hide()


func _on_customer_timer_timeout() -> void:
	if not customer_in_store:
		customer_in_store = true
	else:
		return 
		
	randomize()
		
	var new_customer = c.find_random_customer()
	new_customer.store = self
	new_customer.counter = $CounterDestination
	new_customer.return_basket = $ReturnBasketLocation
	new_customer.exit = $Door
	new_customer.position = $Door.position
	new_customer.website = website
	
	var destinations = []
	
	if new_customer.customer_data.goal == 'return':
		# set destinations as counter, then door again
		destinations.append($ReturnBasketLocation)
	else: # renting
		
		for _i in randi() % 5: # set customer desintations to random shelves then counter
			destinations.append(shelf_desinations.get_children().pick_random())
		destinations.append($CounterDestination)
		
	add_child(new_customer)
	a.play_random_sfx('storefront_door_entry', $Deco/DoorSprite)
	
	await get_tree().create_timer(2).timeout
	
	new_customer.enter_store(destinations)
	
	$CustomerTimer.wait_time = clamp(randi() % 30, 1, 30)


func _on_rug_body_entered(body: Node2D) -> void:
	if body.name == 'Player' or body.has_meta('customer'):
		print(body.name, ' stepped ON rug')
		body.on_carpet = true
		# if stepping off carpet and playing footstep sfx, cutover to tile sfx at same position
		if body.footsteps_player and body.footsteps_player.playing:
			body.footsteps_player.stop()
			body.footsteps_player.queue_free()
			body.footsteps_player = a.play_random_sfx('footstep_carpet', body)
			body.footsteps_player.finished.connect(body._on_footsteps_finished)

func _on_rug_body_exited(body: Node2D) -> void:
	if body.name == 'Player' or body.has_meta('customer'):
		print(body.name, ' stepped OFF rug')
		body.on_carpet = false
		# if stepping off carpet and playing footstep sfx, cutover to tile sfx at same position
		if body.footsteps_player and body.footsteps_player.playing:
			body.footsteps_player.stop()
			body.footsteps_player.queue_free()
			body.footsteps_player = a.play_random_sfx('footstep_tile', body)
			body.footsteps_player.finished.connect(body._on_footsteps_finished)
