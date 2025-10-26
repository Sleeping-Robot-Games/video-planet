extends VBoxContainer

var log_line_scene = preload('res://shared/log_line.tscn')

func _ready() -> void:
	# game pauses when website is open, this allows logs to still fade
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	g.add_log_line.connect(_on_add_log_line)

func _on_add_log_line(msg: String, type: String) -> void:
	var log_color = Color.WHITE
	if type == 'SUCCESS':
		log_color = Color.GREEN
	elif type == 'NEGATIVE':
		log_color = Color.RED
	var log_line = log_line_scene.instantiate()
	log_line.set_log_messsage(msg, log_color)
	add_child(log_line)
	move_child(log_line, 0)
	
