extends Sprite2D

@export_enum('HORROR', 'SCI-FI', 'ROMANCE', 'COMEDY') var genre: String

var spaces: Dictionary = {
	1: { 'shelf': '01', 'space': 'a', 'movie_id': null},
	2: { 'shelf': '01', 'space': 'b', 'movie_id': null},
	3: { 'shelf': '01', 'space': 'c', 'movie_id': null},
	4: { 'shelf': '01', 'space': 'd', 'movie_id': null},
	5: { 'shelf': '01', 'space': 'e', 'movie_id': null},
	6: { 'shelf': '01', 'space': 'f', 'movie_id': null},
}

var stocked_count: int = 0

func _ready() -> void:
	# init stocked movies
	for movie_id in m.inventory.keys():
		attempt_add_movie(movie_id)

func stock_movie(movie_id: String):
	attempt_add_movie(movie_id)

func attempt_add_movie(movie_id: String):
	var movie = m.inventory[movie_id]
	if movie.status == 'STOCKED' and movie.genre == genre:
		stocked_count += 1
		if stocked_count > 36:
			return
		var shelf_space: Dictionary = spaces[stocked_count]
		shelf_space.movie_id = movie_id
		var shelf_node: TextureRect = get_node(shelf_space.shelf + '/' + shelf_space.space)
		shelf_node.texture = load('res://movies/covers/%s.png' % movie_id)
		shelf_node.show()
