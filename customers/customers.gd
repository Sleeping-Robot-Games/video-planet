extends Node

var customer_scene: PackedScene = preload("res://customers/customer.tscn")

var customer_name_pool = [
	"Ari W", "Ben T", "Carla V", "Dana M",
	"Eric Z", "Faye L", "Gio H", "Holly C"
]

var genre_pool = ["HORROR", "SCI-FI", "ROMANCE", "COMEDY"]

var customers: Dictionary = {} # key = name, value = data dict


func generate_customer():
	var customer_name = customer_name_pool.pick_random()
	var goal
	if randf() <= 0.4:
		goal = 'return'
	else:
		goal =  "rent"
		

	var customer_data = {
		"name": customer_name,
		"fave_genre": genre_pool.pick_random(),
		"friendship_level": 0,
		"extrovert": randf() > 0.5,
		"goal": goal,
		"movie_id": null,
		"movie_data": null
	}

	# Returning customers should already have a movie checked out
	if goal == "return":
		var found := false
		
		for movie_id in m.inventory.keys():
			var movie = m.inventory[movie_id]
			if movie.status == "CHECKED OUT" and movie.location == customer_name:
				customer_data.movie_id = movie_id
				customer_data.movie_data = movie
				found = true
				break
		
		# No movie found? Generate movie
		if not found:
			## TODO: Use generate movie function once it's created
			
			var new_movie_id := str(randi() % 300 + 100).pad_zeros(3)
			var new_genre = genre_pool.pick_random()
			
			var new_movie := {
				"title": "Lost in the Couch",
				"genre": new_genre,
				"status": "CHECKED OUT",
				"location": customer_name,
				"reviews": []
			}
			
			customer_data.movie_id = new_movie_id
			customer_data.movie_data = new_movie
			m.inventory[new_movie_id] = new_movie

	# Keep track of this customer
	customers[customer_name] = customer_data

	# Create NPC scene
	var npc = customer_scene.instantiate()
	npc.name = customer_name
	npc.init(customer_data)

	print("NEW CUSTOMER: ", customer_name, 
		" → ", goal, " fav=", customer_data.fave_genre)

	return npc
