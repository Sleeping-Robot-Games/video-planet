extends Node2D

# Constants
const SPAWN_POS_NEW_DAY = Vector2(272, 140)
const SPAWN_POS_CONTINUING = Vector2(57, 139)
const FADE_DURATION = 0.5
const INITIAL_FADE_INTERVAL = 0.25
const SHIFT_DURATION_SECONDS = 300.0
const BACKROOM_SHIFT_TIME = 13
const STOREFRONT_SHIFT_TIME = 17
const MAX_SHELF_DESTINATIONS = 5
const CUSTOMER_ENTRY_DELAY = 2.0
const CUSTOMER_SPAWN_TIMER_MAX = 30

@onready var backroom_label: Label = $HUD/BackroomLabel
@onready var fade_black: ColorRect = $HUD/FadeBlack
@onready var shelf_destinations = $ShelfDestinations
@onready var dialog = $HUD/Dialogue
@onready var website = $HUD/Website
@onready var shift_clock_label: Label = $HUD/ShiftClockLabel
@onready var front_door_label: Label = $HUD/FrontDoorLabel
@onready var end_of_day_modal = $HUD/EndOfDayModal

@warning_ignore("unused_signal")
signal movie_return_to_backlog(movie_id: String, movie_data: Dictionary, customer_name: String)

var music_player: AudioStreamPlayer

var customer_in_store = false

func _ready() -> void:
	_setup_music()
	_setup_fade_screen()
	init_shelves()

	if g.is_new_game:
		_handle_new_game_start()
	else:
		_handle_continuing_game()

	_connect_ui_buttons()
	update_clock_display()

func _setup_music() -> void:
	var bgm_pool = ['storefront_bgm_1', 'storefront_bgm_2']
	music_player = a.play_music(bgm_pool.pick_random())
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS

func _setup_fade_screen() -> void:
	$Player.position = SPAWN_POS_NEW_DAY if g.is_new_day_start else SPAWN_POS_CONTINUING
	fade_black.color = Color.BLACK
	fade_black.show()

func _handle_new_game_start() -> void:
	g.no_computer = true
	var tween = get_tree().create_tween()
	tween.tween_interval(FADE_DURATION)
	tween.tween_callback(a.play_random_sfx.bind('storefront_door_entry'))
	tween.tween_property(fade_black, 'modulate:a', 0.5, FADE_DURATION)
	tween.tween_callback($HUD/Dialogue.open.bind('There are barely any movies in stock! \n
	I better get to the backroom and \n
	start rewinding to fill this place back up before we open!'))
	tween.tween_property(fade_black, 'modulate:a', 0.0, FADE_DURATION)
	tween.tween_callback(fade_black.hide)
	tween.tween_callback(unfreeze_player)
	tween.tween_callback(func(): g.is_new_day_start = false)

	show_backroom_label()
	g.is_new_game = false

func _handle_continuing_game() -> void:
	# Only start customer timer if we're in Shift 2 (storefront shift)
	if g.is_storefront_shift():
		$CustomerTimer.start()

	var tween = get_tree().create_tween()
	tween.tween_interval(INITIAL_FADE_INTERVAL)
	tween.tween_property(fade_black, 'modulate:a', 0.5, FADE_DURATION)
	tween.tween_callback(fade_black.hide)
	tween.tween_callback(unfreeze_player)
	tween.tween_callback(func(): g.is_new_day_start = false)

func _process(delta: float) -> void:
	if g.is_shift_active:
		g.shift_time_remaining -= delta

		# Stop timer at 0, don't go negative
		if g.shift_time_remaining <= 0:
			g.shift_time_remaining = 0
			g.is_shift_active = false
			g.shifts_completed += 1

			# Toggle shift time for next shift
			if g.shift_start_time == BACKROOM_SHIFT_TIME:
				g.shift_start_time = STOREFRONT_SHIFT_TIME
			else:
				g.shift_start_time = BACKROOM_SHIFT_TIME
				g.is_day_complete = true
				$CustomerTimer.stop()
				print("Day complete! Go to the front door to leave.")

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

func _is_valid_actor(body: Node2D) -> bool:
	return body.name == 'Player' or body.has_meta('customer')

func _update_footstep_sfx(body: Node2D, sfx_type: String) -> void:
	if body.footsteps_player and body.footsteps_player.playing:
		body.footsteps_player.stop()
		body.footsteps_player.queue_free()
		body.footsteps_player = a.play_random_sfx(sfx_type, body)
		body.footsteps_player.finished.connect(body._on_footsteps_finished)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and front_door_label.visible:
		_handle_front_door_interaction()
		return

	if event.is_action_pressed("interact") and backroom_label.visible:
		_handle_backroom_interaction()

func _handle_front_door_interaction() -> void:
	front_door_label.hide()
	end_of_day_modal.show()
	g.player_movement_disabled = true
	$CustomerTimer.stop()

func _handle_backroom_interaction() -> void:
	# Prevent backroom access during storefront shift
	if g.is_storefront_shift():
		return

	# Skip to next shift if currently in backroom shift
	if g.is_backroom_shift():
		g.shift_start_time = STOREFRONT_SHIFT_TIME
		g.shift_time_remaining = SHIFT_DURATION_SECONDS
		update_clock_display()

	# Start the shift if none is active
	if not g.is_shift_active:
		g.is_shift_active = true
		g.current_shift = "backroom"
		g.shift_time_remaining = SHIFT_DURATION_SECONDS

	# Transition to backroom scene
	music_player.stop()
	music_player.queue_free()
	dialog.close()
	get_tree().change_scene_to_file("res://backroom/backroom.tscn")


func _on_back_room_door_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		if g.is_storefront_shift():
			backroom_label.text = "Backroom is closed during this shift!"
		else:
			backroom_label.text = "PRESS 'E' to Rewind VHS Tapes"
		backroom_label.show()


func _on_back_room_door_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.hide()


func show_backroom_label() -> void:
	$HUD/BackroomEntranceLabel.show()

func hide_backroom_label() -> void:
	$HUD/BackroomEntranceLabel.hide()


func _on_customer_timer_timeout() -> void:
	if not _should_spawn_customer():
		return

	customer_in_store = true
	randomize()

	var new_customer = _create_and_configure_customer()
	if not new_customer:
		return

	var destinations = _determine_customer_destinations(new_customer)
	if destinations.is_empty():
		return

	_spawn_customer_with_delay(new_customer, destinations)
	_reschedule_customer_timer()

func _should_spawn_customer() -> bool:
	if g.is_day_complete:
		return false
	if not g.is_storefront_shift():
		return false
	if customer_in_store:
		return false
	return true

func _create_and_configure_customer() -> Node:
	var new_customer = c.find_random_customer()
	if not new_customer:
		push_error("Failed to find random customer")
		customer_in_store = false
		return null

	new_customer.store = self
	new_customer.counter = $CounterDestination
	new_customer.return_basket = $ReturnBasketLocation
	new_customer.exit = $Door
	new_customer.position = $Door.position
	new_customer.website = website
	return new_customer

func _determine_customer_destinations(customer: Node) -> Array:
	var destinations = []

	if customer.customer_data.goal == 'return':
		destinations.append($ReturnBasketLocation)
	else: # renting
		var shelves = shelf_destinations.get_children()
		if shelves.is_empty():
			push_error("No shelf destinations available")
			customer_in_store = false
			customer.queue_free()
			return []

		for _i in randi() % MAX_SHELF_DESTINATIONS:
			destinations.append(shelves.pick_random())
		destinations.append($CounterDestination)

	return destinations

func _spawn_customer_with_delay(customer: Node, destinations: Array) -> void:
	add_child(customer)
	a.play_random_sfx('storefront_door_entry', $Deco/DoorSprite)

	await get_tree().create_timer(CUSTOMER_ENTRY_DELAY).timeout
	customer.enter_store(destinations)

func _reschedule_customer_timer() -> void:
	$CustomerTimer.wait_time = clamp(randi() % CUSTOMER_SPAWN_TIMER_MAX, 1, CUSTOMER_SPAWN_TIMER_MAX)


func _on_rug_body_entered(body: Node2D) -> void:
	if _is_valid_actor(body):
		print(body.name, ' stepped ON rug')
		body.on_carpet = true
		_update_footstep_sfx(body, 'footstep_carpet')

func _on_rug_body_exited(body: Node2D) -> void:
	if _is_valid_actor(body):
		print(body.name, ' stepped OFF rug')
		body.on_carpet = false
		_update_footstep_sfx(body, 'footstep_tile')


func _on_front_door_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		# Don't show during new day start animation
		if g.is_new_day_start:
			return
		# Show if day is complete OR if in Shift 2 (allow early day ending)
		if g.is_day_complete or (g.is_shift_active and g.shift_start_time == 17):
			front_door_label.show()


func _on_front_door_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		front_door_label.hide()


func _on_continue_next_day_btn_pressed() -> void:
	# Hide modal
	end_of_day_modal.hide()

	# Fade out
	fade_black.show()
	var tween = get_tree().create_tween()
	tween.tween_property(fade_black, 'modulate:a', 1.0, FADE_DURATION)
	tween.tween_callback(func():
		# Start new day
		g.start_new_day()
		# Reload storefront scene
		get_tree().change_scene_to_file("res://storefront/storefront.tscn")
	)
