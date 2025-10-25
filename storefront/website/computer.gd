extends Sprite2D

@onready var website: ColorRect = $'../../Website'

func _input(event):
	if event.is_action_pressed("interact") and $PressKey.visible:
		website.show()
		get_tree().paused = true


func _on_computer_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		# TODO joypad support
		$PressKey.show()


func _on_computer_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		# TODO joypad support
		$PressKey.hide()
