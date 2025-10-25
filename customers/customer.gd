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

@export var destination: Node2D 


var last_facing: String = "down" # or "back" depending on how you name directions


var current_target: Node2D
var arrived := false


func _ready():
	nav_agent.path_desired_distance = 8.0
	nav_agent.target_desired_distance = 8.0
	nav_agent.avoidance_enabled = true

	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.navigation_finished.connect(_on_arrived)

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
	arrived = true
	velocity = Vector2.ZERO
	_play_idle()
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
	_pick_new_target()


func _pick_new_target():
	if not destination:
		return

	arrived = false
	current_target = destination
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
