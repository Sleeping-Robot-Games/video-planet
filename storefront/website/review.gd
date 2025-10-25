extends HBoxContainer

@onready var thumb_icon: TextureRect = $ThumbIcon
@onready var background: ColorRect = $BG
@onready var review: Label = $BG/Review

func set_review(user: String, content: String, is_positive: bool, bg_color: Color) -> void:
	review.text = '%s: %s' % [user, content]
	var thumb_icon_path = 'res://movies/assets/thumbs_%s_small.png' % 'up' if is_positive else 'down'
	thumb_icon.texture = load(thumb_icon_path)
	background.color = bg_color
