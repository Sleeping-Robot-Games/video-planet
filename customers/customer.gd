extends CharacterBody2D

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var speed: float = 85.0
@export var destinations: Array[Node2D]

var current_target: Node2D
var arrived := false


func _ready():
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 6.0

	# Connect signals
	nav_agent.navigation_finished.connect(_on_arrived)
	nav_agent.velocity_computed.connect(_on_velocity_computed)

	_pick_new_target()


func _physics_process(delta):
	if arrived:
		velocity = Vector2.ZERO
		return

	if not current_target:
		return

	nav_agent.target_position = current_target.global_position
	nav_agent.set_velocity(global_position.direction_to(nav_agent.target_position) * speed)


func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()


func _pick_new_target():
	if destinations.is_empty():
		return

	arrived = false
	current_target = destinations.pick_random()
	nav_agent.target_position = current_target.global_position


func _on_arrived():
	arrived = true
	velocity = Vector2.ZERO

	# Wait before choosing a new point (look around)
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
	_pick_new_target()
