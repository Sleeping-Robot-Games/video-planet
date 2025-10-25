extends CharacterBody2D

### TODO NOTES ###
# - Stop walking and face player when player approaches
# - Have a purpose when they enter, renter or returner
#	- Returners just go to the counter and then walk back out
#	- Renters come in to browse the shelves, then if not interrupted go to the counter
# - When player interacts, dialog appears and they say their purpose
	# - renters will have option to open the website from dialog


@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim: AnimationPlayer = $AnimationPlayer

@export var speed: float = 85.0

var destinations = []

var store


var last_facing: String = "down" # or "back" depending on how you name directions


var current_target: Node2D
var arrived := false

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
	nav_agent.path_desired_distance = 8.0
	nav_agent.target_desired_distance = 8.0
	nav_agent.avoidance_enabled = true

	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.navigation_finished.connect(_on_arrived)


func init(data):
	customer_data = data
	
func enter_store(dest_array):
	destinations = dest_array
	
	_pick_new_target()

func _physics_process(_delta):
	if arrived or not current_target:
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
			anim.play("sprite_animations/walk_right")
		else:
			last_facing = "left"
			anim.play("sprite_animations/walk_left")
	else:
		if vel.y > 0:
			last_facing = "down"
			anim.play("sprite_animations/walk_down")
		else:
			last_facing = "up"
			anim.play("sprite_animations/walk_up")


func _play_idle():
	anim.play("sprite_animations/idle_back")
	
	#match last_facing:
		#"right": anim.play("sprite_animations/idle_right")
		#"left": anim.play("sprite_animations/idle_left")
		#"down": anim.play("sprite_animations/idle_back")
		#"up": anim.play("sprite_animations/idle_front")
