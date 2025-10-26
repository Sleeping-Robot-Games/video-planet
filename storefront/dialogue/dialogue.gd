extends Panel

@onready var storefront: Node2D = $"../.."
@onready var dialog_msg: Label = $Margin/VBoxContainer/Message
@onready var button_container = $Margin/VBoxContainer/ButtonContainer

var current_options = []

func _ready() -> void:
	var buttons = button_container.get_children()
	for i in range(buttons.size()):
		var btn = buttons[i]

		btn.pressed.connect(_on_choice_pressed.bind(i))

		btn.hide() # default hidden until options shown

func _on_choice_pressed(index: int):
	## TODO: do stuff???
	var selected_option = current_options[index]
	print(selected_option)
	close()
	
func open(msg: String, options: Array = []) -> void:
	current_options = options
	g.is_dialogue_open = true
	dialog_msg.text = msg

	var buttons = button_container.get_children()

	for i in range(buttons.size()):
		var btn = buttons[i]
		if i < options.size():
			btn.text = str(options[i])
			btn.show()
		else:
			btn.hide()

	show()

func perform_bounce() -> void:
	var original_position = position 
	var offset_pos = original_position - Vector2(0, 5)

	var tween = get_tree().create_tween()

	tween.tween_property(self, "position", offset_pos, 0.1) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "position", original_position, 0.1) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_IN) \
		.set_delay(0.1)


func close() -> void:
	hide()
	current_options = []
	g.is_dialogue_open = false
