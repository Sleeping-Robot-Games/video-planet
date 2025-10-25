extends ColorRect

var listing_scene = preload('res://storefront/website/listing.tscn')

@onready var listings_container: VBoxContainer = $Container/Body/MovieList

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# init movie listings
	for movie_id in m.inventory.keys():
		var listing = listing_scene.instantiate()
		listings_container.add_child(listing)
		listing.set_movie(movie_id)

func _on_close_button_pressed() -> void:
	get_tree().paused = false
	hide()
