extends Sprite2D

@onready var website: TextureRect = $'../../HUD/Website'

func _input(event):
	if event.is_action_pressed('interact') and $PressKey.visible:
		website.open_by_storefront_computer()


func _on_computer_body_entered(body: Node2D) -> void:
	if body.name == 'Player' and not g.no_computer:
		# TODO joypad support
		$PressKey.show()


func _on_computer_body_exited(body: Node2D) -> void:
	if body.name == 'Player':
		# TODO joypad support
		$PressKey.hide()
