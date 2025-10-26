extends Panel

@onready var storefront: Node2D = $"../.."
@onready var dialog_msg: Label = $Margin/VBoxContainer/Message
@onready var button_container = $Margin/VBoxContainer/ButtonContainer
@onready var website = $"../Website"

var current_options = []
var current_customer_name

func _ready() -> void:
	website.rented_movie_selected.connect(_on_rented_movie)
	var buttons = button_container.get_children()
	for i in range(buttons.size()):
		var btn = buttons[i]

		btn.pressed.connect(_on_choice_pressed.bind(i))

		btn.hide() # default hidden until options shown

func _on_choice_pressed(index: int):
	match index:
		0:
			website.open_by_dialog(current_customer_name)

func _on_rented_movie(movie_id: String):
	dialog_msg.text = 'Thanks looking forward to watching ' + m.inventory[movie_id].title
	for btn in button_container.get_children():
		btn.hide()

func open(msg: String, customer_name: String = "", options: Array = []) -> void:
	current_customer_name = customer_name
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
