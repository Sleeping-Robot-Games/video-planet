extends TextureRect

var listing_scene = preload('res://website/listing.tscn')

@onready var listings_container: VBoxContainer = $Container/Body/MovieList
@onready var search_input: LineEdit = $Container/Header/VBox/Filters/Search
@onready var genre_input: OptionButton = $Container/Header/VBox/Filters/Genre/Picker
@onready var genre_clear: Button = $Container/Header/VBox/Filters/Genre/Spacer/ClearButton
@onready var status_input: OptionButton = $Container/Header/VBox/Filters/Status/Picker
@onready var status_clear: Button = $Container/Header/VBox/Filters/Status/Spacer/ClearButton

signal rewind_movie_selected(movie_id: String)

var total_reviews: int = 0
var positive_reviews: int = 0
var next_unlock: int = -1

func _ready():
	# game pauses when website is open, this allows website to remain active during game pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# init movie listings
	for movie_id in m.inventory.keys():
		var listing = listing_scene.instantiate()
		listings_container.add_child(listing)
		listing.init(self)
		listing.set_movie(movie_id)
		# tally reviews
		for review in m.inventory[movie_id].reviews:
			total_reviews += 1
			if review.is_positive:
				positive_reviews += 1
		# calc next unlock
		for decoration in g.decoration_unlocks:
			if positive_reviews >= decoration.unlocks_at:
				decoration.is_unlocked = true
			else:
				next_unlock = decoration.unlocks_at - positive_reviews
				break
		# set next unlock text
		if next_unlock == -1:
			$ReviewRewards/NextUnlock.text = 'All Decorations Unlocked!'
		else:
			$ReviewRewards/NextUnlock.text = '[img=16x16]res://movies/assets/thumbs_up_small.png[/img] Til Next Decoration Unlock: %d' % next_unlock
		# set total reviews text
		$ReviewRewards/TotalReviews.text = 'Total Reviews: %d' % total_reviews

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	hide()

func filter_movies() -> void:
	var search_filter_text: String = search_input.text
	var genre_filter_idx: int = genre_input.selected
	var genre_filter_text: String = genre_input.get_item_text(genre_filter_idx).to_upper()
	var status_filter_idx: int = status_input.selected
	var status_filter_text: String = status_input.get_item_text(status_filter_idx).to_upper()
	
	for listing in listings_container.get_children():
		var movie_id = listing.movie_id
		var show_listing: bool = true
		var filters_active: bool = search_filter_text or genre_filter_idx or status_filter_idx
		if filters_active:
			var movie = m.inventory[movie_id]
			var search_matches: bool = search_filter_text.to_lower() in movie.title.to_lower()
			var genre_matches: bool = genre_filter_text == movie.genre
			var status_matches: bool = status_filter_text == movie.status
			# if filters active, movie must match all active filters to stay listed
			if search_filter_text and genre_filter_idx and status_filter_idx:
				show_listing = search_matches and genre_matches and status_matches
			elif search_filter_text and genre_filter_idx and not status_filter_idx:
				show_listing = search_matches and genre_matches
			elif search_filter_text and not genre_filter_idx and status_filter_idx:
				show_listing = search_matches and status_matches
			elif search_filter_text and not genre_filter_idx and not status_filter_idx:
				show_listing = search_matches
			elif not search_filter_text and genre_filter_idx and status_filter_idx:
				show_listing = genre_matches and status_matches
			elif not search_filter_text and not genre_filter_idx and status_filter_idx:
				show_listing = status_matches
			elif not search_filter_text and genre_filter_idx and not status_filter_idx:
				show_listing = genre_matches
		listing.visible = show_listing

func _on_search_text_changed(_new_text: String) -> void:
	filter_movies()

func _on_genre_item_selected(index: int) -> void:
	filter_movies()
	genre_clear.visible = bool(index)

func _on_status_item_selected(index: int) -> void:
	filter_movies()
	status_clear.visible = bool(index)

func open_by_storefront_computer() -> void:
	search_input.text = ''
	search_input.editable = true
	genre_input.selected = 0
	genre_input.disabled = false
	genre_clear.hide()
	status_input.selected = 0
	status_input.disabled = false
	status_clear.hide()
	for listing in listings_container.get_children():
		listing.rewind_button.hide()
	filter_movies()
	show()
	get_tree().paused = true

func open_by_backroom_computer() -> void:
	search_input.text = ''
	search_input.editable = false
	genre_input.selected = 0
	genre_input.disabled = true
	genre_clear.hide()
	status_input.selected = 2
	status_input.disabled = true
	status_clear.hide()
	for listing in listings_container.get_children():
		listing.rewind_button.show()
	filter_movies()
	show()
	get_tree().paused = true

func backroom_rewind_selected(movie_id: String) -> void:
	get_tree().paused = false
	rewind_movie_selected.emit(movie_id)
	hide()

func _on_clear_genre_pressed() -> void:
	genre_input.select(0)
	genre_clear.hide()
	filter_movies()

func _on_clear_status_pressed() -> void:
	status_input.select(0)
	status_clear.hide()
	filter_movies()
