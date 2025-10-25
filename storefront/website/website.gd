extends VBoxContainer

var listing_scene = preload('res://storefront/website/listing.tscn')

@onready var listings_container: VBoxContainer = $Body/MovieList

func _ready():
	# init movie listings
	for movie_id in m.inventory.keys():
		var listing = listing_scene.instantiate()
		listings_container.add_child(listing)
		listing.set_movie(movie_id)
		
