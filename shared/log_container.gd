extends VBoxContainer

var log_line_scene = preload('res://shared/log_line.tscn')

func _ready() -> void:
	g.add_log_line.connect(_on_add_log_line)

func _on_add_log_line(msg: String, color: Color = Color.WHITE) -> void:
	var log_line = log_line_scene.instantiate()
	log_line.set_log_messsage(msg, color)
	add_child(log_line)
	move_child(log_line, -1)
