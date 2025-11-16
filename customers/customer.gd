extends CharacterBody2D

@onready var store_front = get_parent()
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var personality_responses = preload("res://customers/personality_responses.gd").new()

@export var speed: float = 85.0

var on_carpet: bool = false
var footsteps_player: AudioStreamPlayer2D = null
var website

var destinations = []

var store

var last_facing: String = "down" # or "back" depending on how you name directions

var current_target: Node2D
var arrived = false

var player_interacting = false
var player_ref

var customer_data = {}

var exit: Node2D
var counter: Node2D
var return_basket: Node2D

## data example
	#var customer_data = {
		#"name": customer_name,
		#"fave_genre": genre_pool.pick_random(),
		#"friendship_level": 0,
		#"extrovert": randf() > 0.5,
		#"goal": goal,
		#"movie_id": null,
		#"movie_data": null
	#}

func _ready():
	set_meta('customer', true)
	m.rented_movie_selected.connect(_on_rented_movie)

	nav_agent.path_desired_distance = 8.0
	nav_agent.target_desired_distance = 8.0
	nav_agent.avoidance_enabled = true
	nav_agent.radius = 16.0  # Increase personal space for better multi-customer navigation
	nav_agent.neighbor_distance = 50.0  # How far to look for other agents
	nav_agent.max_neighbors = 5  # Max number of neighbors to avoid

	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.navigation_finished.connect(_on_arrived)

	_play_idle()

func _exit_tree():
	# Safeguard: Always remove customer from array when this node is removed
	# This handles edge cases where customer doesn't reach exit (scene change, navigation failure, etc.)
	if store and is_instance_valid(store):
		store.remove_customer(self)
	
func init(data):
	customer_data = data
	$Sprite2D.texture = load(data.sprite)
	$Name.text = name
	
func enter_store(dest_array):
	destinations = dest_array
	
	_pick_new_target()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_interacting:
		if customer_data.goal == 'rent':
			_start_rental_conversation()
		else:
			store_front.dialog.open('Just returning '+ m.inventory[customer_data.movie_id].title + '\n it was quite the movie...')

func _start_rental_conversation():
	# Stage 0: Select cheap movie if not already selected
	if customer_data.selected_cheap_movie == null:
		_select_cheap_movie()

	# Stage 1: Small talk (personality hint)
	if customer_data.conversation_stage == 0:
		customer_data.conversation_stage = 1
		var small_talk = personality_responses.get_small_talk(customer_data.personality_type)
		store_front.dialog.open(
			small_talk,
			name,
			["Nice! What can I help you with?"],
			_on_stage1_choice
		)

func _select_cheap_movie():
	# Find cheapest STOCKED movie in wanted genre
	var stocked_movies = []
	for movie_id in m.inventory.keys():
		var movie = m.inventory[movie_id]
		if movie.status == "STOCKED" and movie.genre == customer_data.wanted_genre:
			stocked_movies.append({"id": movie_id, "data": movie})

	if stocked_movies.is_empty():
		# Fallback: pick any stocked movie
		for movie_id in m.inventory.keys():
			var movie = m.inventory[movie_id]
			if movie.status == "STOCKED":
				stocked_movies.append({"id": movie_id, "data": movie})

	if not stocked_movies.is_empty():
		var selected = stocked_movies.pick_random()
		customer_data.selected_cheap_movie = selected

func _on_stage1_choice(_choice_index: int):
	# Stage 2: Genre request + mention cheap movie
	customer_data.conversation_stage = 2

	var genre_texts = {
		'HORROR': ['scary', 'spooky', 'creepy', 'something that will keep me up tonight', 'a real fright', 'something dark and chilling'],
		'SCI-FI': ['futuristic', 'about space', 'with robots or aliens', 'high-tech', 'something out of this world', 'a mind-bender'],
		'ROMANCE': ['romantic', 'about falling in love', 'something heartfelt', 'a good love story', 'sweet and emotional', 'something cozy with a happy ending'],
		'COMEDY': ['funny', 'lighthearted', 'something to laugh at', 'a good laugh', 'goofy', 'something cheerful']
	}
	var wanted_genre_text = genre_texts.get(customer_data.wanted_genre, ['interesting']).pick_random()

	var cheap_movie_title = customer_data.selected_cheap_movie.data.title
	var cheap_movie_price = m.DIFFICULTY_CONFIG[customer_data.selected_cheap_movie.data.difficulty_tier].money_value

	var message = "I'm looking for something %s...\nI'll just grab '%s' for $%d unless you can recommend something better?" % [
		wanted_genre_text,
		cheap_movie_title,
		cheap_movie_price
	]

	store_front.dialog.open(
		message,
		name,
		["Open Movie Catalog"],
		_on_stage2_choice
	)

func _on_stage2_choice(_choice_index: int):
	# Open website - player will select a movie
	store_front.dialog.close()
	store_front.website.open_by_dialog(name)

func _show_persuasion_check(movie_id: String):
	var movie_data = m.inventory[movie_id]
	var persuasion_data = personality_responses.get_persuasion_options(customer_data.personality_type)

	# Store which option is correct
	customer_data.persuasion_correct_index = persuasion_data.correct_index

	# Create the message based on genre match
	var message = ""
	if customer_data.wanted_genre == movie_data.genre:
		message = "'%s' huh? Why do you think I'd like it?" % movie_data.title
	else:
		message = "'%s'? That's not quite what I was looking for... Why this one?" % movie_data.title

	# Show the persuasion dialog with 3 options
	store_front.dialog.open(
		message,
		name,
		persuasion_data.options,
		_on_persuasion_choice
	)

func _on_persuasion_choice(choice_index: int):
	# Check if player picked the correct response
	var success = (choice_index == customer_data.persuasion_correct_index)

	if success:
		_handle_persuasion_success()
	else:
		_handle_persuasion_failure()

func _handle_persuasion_success():
	# Customer accepts the player's recommendation
	var movie_id = customer_data.player_recommended_movie
	var movie_data = m.inventory[movie_id]
	var rental_price = m.DIFFICULTY_CONFIG[movie_data.difficulty_tier].money_value

	store_front.dialog.open(
		"You know what? You're absolutely right! I'll take '%s' for $%d!" % [movie_data.title, rental_price],
		name,
		[]
	)

	# Actually rent the movie
	_finalize_rental(movie_id)

func _handle_persuasion_failure():
	# Customer rejects and takes the cheap movie instead
	var cheap_movie_id = customer_data.selected_cheap_movie.id
	var cheap_movie_data = customer_data.selected_cheap_movie.data
	var cheap_price = m.DIFFICULTY_CONFIG[cheap_movie_data.difficulty_tier].money_value

	store_front.dialog.open(
		"Hmm, I don't think so... I'll just stick with '%s' for $%d." % [cheap_movie_data.title, cheap_price],
		name,
		[]
	)

	# Rent the cheap movie instead
	_finalize_rental(cheap_movie_id)

func _finalize_rental(movie_id: String):
	var movie_data = m.inventory[movie_id]
	var rental_price = m.DIFFICULTY_CONFIG[movie_data.difficulty_tier].money_value

	# Update movie status
	m.inventory[movie_id].status = "CHECKED OUT"
	m.inventory[movie_id].location = customer_data.name

	# Award money
	g.money_earned.emit(rental_price, 'rental')

	# Customer leaves
	await get_tree().create_timer(2.0).timeout
	store_front.dialog.close()
	destinations = []
	destinations.append(exit)
	_pick_new_target()


func _on_rented_movie(_movie_id: String, customer_name: String):
	if customer_name == customer_data.name:
		# Store the player's recommended movie
		customer_data.player_recommended_movie = _movie_id
		customer_data.conversation_stage = 3

		# Stage 3: Persuasion check
		_show_persuasion_check(_movie_id)

func _process(_delta: float) -> void:
	if anim_player.is_playing() and anim_player.current_animation.begins_with('walk_') and anim_player.current_animation_position in [0.0, 0.4]:
		footsteps()

func _physics_process(_delta):
	if arrived or not current_target or player_interacting:
		return

	# Just set the target — do NOT manually steer
	nav_agent.target_position = current_target.global_position

	# Request next safe velocity
	if nav_agent.is_navigation_finished():
		return

	var next_velocity = nav_agent.get_next_path_position() - global_position
	nav_agent.set_velocity(next_velocity.normalized() * speed)

	_play_animation(velocity)


func _on_velocity_computed(safe_velocity: Vector2):
	if player_interacting:
		velocity = Vector2.ZERO
		_play_idle()
		return

	velocity = safe_velocity
	move_and_slide()


func _on_arrived():
	var dest = destinations.pop_front()
	arrived = true
	velocity = Vector2.ZERO
	match dest:
		return_basket:
			destinations.append(exit)
			_play_idle()
			if not customer_data.movie_data:
				print('why was customer_data.movie_data null? ', customer_data)
				_pick_new_target()
				return
			store_front.movie_return_to_backlog.emit(customer_data.movie_id, customer_data.movie_data, customer_data.name)
			await get_tree().create_timer(randf_range(1.0, 2.0)).timeout
			var chance: int = randi_range(1, 10)
			if customer_data.wanted_genre == customer_data.movie_data.genre:
				# 70% chance to leave a positive review if the customer rented the genre they wanted
				if chance <= 7:
					m.movie_reviewed.emit(true, customer_data.movie_id, customer_data.movie_data, customer_data.name)
			else:
				# otherwise 70% chance to leave negative review
				if chance <= 7:
					m.movie_reviewed.emit(false, customer_data.movie_id, customer_data.movie_data, customer_data.name)
			_pick_new_target()
		counter:
			destinations.append(exit)
			_play_idle()
			await get_tree().create_timer(randf_range(1.0, 10.0)).timeout
		exit:
			store.remove_customer(self)
			a.play_random_sfx('storefront_door_exit', a, {'position': position})
			queue_free()
		_:
			_play_idle()
			await get_tree().create_timer(randf_range(1.0, 10.0)).timeout
			_pick_new_target()


func _pick_new_target():
	if destinations.is_empty():
		await get_tree().create_timer(5).timeout
		
		destinations.append(exit)
		return

	arrived = false
	current_target = destinations[0]
	nav_agent.target_position = current_target.global_position

	# Debug logging
	print("New target: ", current_target.name)
	print("Path available: ", not nav_agent.is_navigation_finished())
	
func _play_animation(vel: Vector2):
	# Determine direction from movement
	if abs(vel.x) > abs(vel.y):
		if vel.x > 0:
			last_facing = "right"
			anim_player.play("sprite_animations/walk_right")
		else:
			last_facing = "left"
			anim_player.play("sprite_animations/walk_left")
	else:
		if vel.y > 0:
			last_facing = "down"
			anim_player.play("sprite_animations/walk_down")
		else:
			last_facing = "up"
			anim_player.play("sprite_animations/walk_up")


func _play_idle():
	if destinations.is_empty():
		
		anim_player.play("sprite_animations/idle_front")
		return
		
	if player_interacting:
		match last_facing:
			"right": anim_player.play("sprite_animations/idle_right")
			"left": anim_player.play("sprite_animations/idle_left")
			"down": anim_player.play("sprite_animations/idle_front")
			"up": anim_player.play("sprite_animations/idle_back")
	else:
		anim_player.play("sprite_animations/idle_back")



func _on_player_watch_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Interact.show()
		player_ref = body
		player_interacting = true
		velocity = Vector2.ZERO
		nav_agent.set_velocity(Vector2.ZERO)

		_face_player()
		_play_idle()



func _on_player_watch_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$Interact.hide()
		if g.is_dialogue_open:
			get_parent().dialog.close()
		player_ref = null
		player_interacting = false
		arrived = false  # Allow movement again
		_pick_new_target()


func _face_player() -> void:
	if not player_ref:
		return
	
	var dir = player_ref.global_position - global_position
	
	if abs(dir.x) > abs(dir.y):
		# Horizontal bias
		if dir.x > 0:
			last_facing = "right"
		else:
			last_facing = "left"
	else:
		# Vertical bias
		if dir.y > 0:
			last_facing = "down"
		else:
			last_facing = "up"


func footsteps() -> void:
	# return if we're already playing sfx
	if footsteps_player and footsteps_player.playing:
		return
	elif footsteps_player and not footsteps_player.playing:
		footsteps_player.queue_free()
	# otherwise 1 in 3 chance to play sfx
	#randomize()
	#var chance: int = randi_range(1, 3)
	#if chance == 1:
	var sfx_name = 'footstep_carpet' if on_carpet else 'footstep_tile'
	footsteps_player = a.play_random_sfx(sfx_name)
	footsteps_player.finished.connect(_on_footsteps_finished)

func _on_footsteps_finished() -> void:
	if footsteps_player:
		footsteps_player.finished.disconnect(_on_footsteps_finished)
		footsteps_player.queue_free()
