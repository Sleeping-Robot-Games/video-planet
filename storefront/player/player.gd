extends CharacterBody2D

@export var speed := 150.0
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var on_carpet: bool = true
var footsteps_player: AudioStreamPlayer2D = null
var last_direction := Vector2.DOWN

func _process(_delta: float) -> void:
	if anim_player.is_playing() and anim_player.current_animation.begins_with('walk_') and anim_player.current_animation_position in [0.0, 0.4]:
		footsteps()

func _physics_process(_delta: float) -> void:
	if g.player_movement_disabled:
		if not anim_player.current_animation.begins_with('idle_'):
			play_idle_animation(last_direction)
		return
	
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	input_vector.y = Input.get_action_strength("walk_down") - Input.get_action_strength("walk_up")
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		last_direction = input_vector
		velocity = input_vector * speed
		move_and_slide()
		play_walk_animation(input_vector)
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle_animation(last_direction)


func play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_player.play("walk_right")
		else:
			anim_player.play("walk_left")
	elif direction.y > 0:
		anim_player.play("walk_down")
	else:
		anim_player.play("walk_up")


func play_idle_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_player.play("idle_right")
		else:
			anim_player.play("idle_left")
	elif direction.y > 0:
		anim_player.play("idle_front")
	else:
		anim_player.play("idle_back")

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
