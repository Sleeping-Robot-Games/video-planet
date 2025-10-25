extends Node2D

@onready var backroom_label = $Backroomdoor/BackroomLabel

func _ready() -> void:
	#NameGenerator.initialize() # TODO move to Title screen for prod build (must only be called once)
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and backroom_label.visible:
		get_tree().change_scene_to_file("res://backroom/backroom.tscn")


func _on_back_room_door_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.show()


func _on_back_room_door_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		backroom_label.hide()
