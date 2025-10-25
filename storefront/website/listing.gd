extends HBoxContainer

var review_scene = preload('res://storefront/website/review.tscn')

@onready var rewind_button: Button = $RewindButton
@onready var movie_poster: TextureRect = $Movie/Poster
@onready var movie_title: Label = $Movie/Details/Title
@onready var genre_border: NinePatchRect = $Movie/Details/Genre/Border
@onready var genre_label: Label = $Movie/Details/Genre/MarginContainer/Label
@onready var status: Label = $Status/State
@onready var location: Label = $Status/Location
@onready var pos_review_count: Label = $ReviewCounts/Counts/Positive/Count
@onready var neg_review_count: Label = $ReviewCounts/Counts/Negative/Count
@onready var reviews_container: VBoxContainer = $Reviews/List

var website: ColorRect = null
var movie_id: String = '000'

func init(_website: ColorRect) -> void:
	website = _website

func set_movie(_movie_id: String):
	# id
	movie_id = _movie_id
	# poster
	movie_poster.texture = load('res://movies/covers/%s.png' % movie_id)
	# title
	movie_title.text = m.inventory[movie_id].title
	# genre
	var genre = m.inventory[movie_id].genre
	genre_label.text = genre
	genre_label.modulate = m.genre_colors[genre]
	genre_border.modulate = m.genre_colors[genre]
	# status
	set_status(m.inventory[movie_id].status, m.inventory[movie_id].location)
	# reset review state
	for stale_review in reviews_container.get_children():
		stale_review.queue_free()
	pos_review_count.text = '0'
	neg_review_count.text = '0'
	# add fresh reviews
	for new_review in m.inventory[movie_id].reviews:
		var review_bg: Color = Color('#00000000') # TODO: alternate between 2 bg colors
		add_review(new_review.user, new_review.content, new_review.is_positive, review_bg)

func set_status(new_status: String, new_location: String) -> void:
	# status
	status.text = '◉ %s' % new_status
	status.modulate = m.status_colors[new_status]
	# location
	location.text = new_location

func add_review(user: String, content: String, is_positive: bool, bg_color: Color) -> void:
		var review_instance = review_scene.instantiate()
		reviews_container.add_child(review_instance)
		review_instance.set_review(user, content, is_positive, bg_color)
		# increment appropriate count
		if is_positive:
			pos_review_count.text = str(int(pos_review_count.text) + 1)
		else:
			neg_review_count.text = str(int(neg_review_count.text) + 1)


func _on_rewind_button_pressed() -> void:
	website.backroom_rewind_selected(movie_id)
