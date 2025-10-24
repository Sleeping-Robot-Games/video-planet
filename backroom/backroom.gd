extends Node2D

@onready var tracking = $VCR/Tracking
@onready var hit_zone = $VCR/Ticker/HitZone
@onready var tick = $VCR/Ticker/Tick
@onready var dial = $VCR/Dial

const DIAL_ROTATE_SPEED = 120.0
const DIAL_ROTATE_MIN = -100.0
const DIAL_ROTATE_MAX = 100.0

var dial_angle = 0.0

var tracking_input_map = {
	"1": null,
	"2": null,
	"3": null,
	"4": null,
	"5": null,
}


func _ready():
	for tracking_button in tracking.get_children():
		tracking_button.pressed.connect(_on_tracking_button_pressed.bind(tracking_button.name))
		tracking_input_map[tracking_button.name] = tracking_button
	

func _on_tracking_button_pressed(number: String):
	print(number)

func _unhandled_input(event: InputEvent):
	for key in tracking_input_map.keys():
		if event.is_action_pressed(key):
			tracking_input_map[key].button_pressed = true


func _process(delta):
	if Input.is_action_pressed('right'):
		dial_angle += DIAL_ROTATE_SPEED * delta
	elif Input.is_action_pressed('left'):
		dial_angle -= DIAL_ROTATE_SPEED * delta
		
	
	dial_angle = clamp(dial_angle, DIAL_ROTATE_MIN, DIAL_ROTATE_MAX)
	dial.rotation_degrees = dial_angle
