extends Panel

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.chain().tween_interval(6.0)
	tween.tween_property(self, 'modulate:a', 0.0, 3.0)
	tween.chain().tween_callback(queue_free)

func set_log_messsage(msg: String, color: Color = Color.WHITE) -> void:
	$MarginContainer/Label.text = msg
	$MarginContainer/Label.add_theme_color_override('font_color', color)
