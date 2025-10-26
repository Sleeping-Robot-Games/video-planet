extends Node

var customer_scene: PackedScene = preload("res://customers/customer.tscn")

var customer_pool: Array = []

var genre_pool = ["HORROR", "SCI-FI", "ROMANCE", "COMEDY"]

var customers: Dictionary = {} # key = name, value = data dict

func _ready():
	var sprite_files = g.files_in_dir("res://customers/sprites/")
	sprite_files.shuffle() # Randomize order so pairing is random

	var names = [
		"Ari W",
		"Avery M",
		"Charlie B",
		"Finley P",
		"Gray J",
		"Hayden G",
		"Kai Z",
		"Quinn R",
		"Rowan G",
		"Skyler X"
	]

	var total_count = min(names.size(), sprite_files.size())

	for i in range(total_count):
		customer_pool.append({
			"name": names[i],
			"sprite": "res://customers/sprites/" + sprite_files[i],
			"friendship_level": 0,
			"extrovert": randf() > 0.5,
		})

func find_random_customer():
	var customer_data = customer_pool.pick_random().duplicate()
	
	var customer_has_movie_already = false
	
	for movie_id in m.inventory.keys():
		var movie = m.inventory[movie_id]
		if movie.status == "CHECKED OUT" and movie.location == customer_data.name:
			customer_has_movie_already = true
			
	var goal = 'return'
	if customer_has_movie_already:
		goal = 'return'
	elif randf() <= 0.7:
		goal =  "rent"

	var goal_data = {
		"goal": goal,
		"wanted_genre": genre_pool.pick_random(),
		"movie_id": null,
		"movie_data": null
	}
	
	customer_data.merge(goal_data, true)

	# Returning customers should already have a movie checked out
	if goal == "return":
		# No movie? Generate movie
		if not customer_has_movie_already:
			var new_movie := m.generate_movie('BACKLOG')
			var new_movie_id := str(randi() % 300 + 100).pad_zeros(3)
			customer_data.movie_id = new_movie_id
			customer_data.movie_data = new_movie
			m.inventory[new_movie_id] = new_movie

	# Keep track of this customer
	customers[customer_data.name] = customer_data.duplicate()

	# Create NPC scene
	var npc = customer_scene.instantiate()
	npc.name = customer_data.name
	npc.init(customer_data)

	print("NEW CUSTOMER: ", customer_data.name, 
		" → ", goal, " fav=", customer_data.wanted_genre)

	return npc
