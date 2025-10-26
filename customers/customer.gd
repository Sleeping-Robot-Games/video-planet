extends CharacterBody2D

### TODO NOTES ###
# - Have a purpose when they enter, renter or returner
#	- Returners just go to the counter and then walk back out
#	- Renters come in to browse the shelves, then if not interrupted go to the counter
# - Stop walking and face player when player approaches
# - When player interacts, dialog appears and they say their purpose
	# - renters will have option to open the website from dialog

@onready var store_front = get_parent()
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var speed: float = 85.0

var on_carpet: bool = true
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
	website.rented_movie_selected.connect(_on_rented_movie)
	
	nav_agent.path_desired_distance = 8.0
	nav_agent.target_desired_distance = 8.0
	nav_agent.avoidance_enabled = true

	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.navigation_finished.connect(_on_arrived)

	_play_idle()
	
func init(data):
	customer_data = data
	$Sprite2D.texture = load(data.sprite)
	$Name.text = name
	
func enter_store(dest_array):
	destinations = dest_array
	
	_pick_new_target()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_interacting:
		store_front.dialog.open('I want a movie, GIMME!', name, ['Open Movie Catalog'])

func _on_rented_movie(_move_id):
	destinations = []
	destinations.append(exit)
	_pick_new_target()

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
	if dest == return_basket:
		destinations.append(exit)
	if dest == counter:
		destinations.append(exit)
	if dest == exit:
		store.customer_in_store = false
		a.play_random_sfx('storefront_door_exit', a, {'position': position})
		queue_free()
		
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
