extends Sprite2D

@export_enum('HORROR', 'SCI-FI', 'ROMANCE', 'COMEDY') var shelf_genre: String

var spaces: Dictionary = {
	1: { 'shelf': '01', 'space': 'a', 'movie_id': null},
	2: { 'shelf': '01', 'space': 'b', 'movie_id': null},
	3: { 'shelf': '01', 'space': 'c', 'movie_id': null},
	4: { 'shelf': '01', 'space': 'd', 'movie_id': null},
	5: { 'shelf': '01', 'space': 'e', 'movie_id': null},
	6: { 'shelf': '01', 'space': 'f', 'movie_id': null},
	7: { 'shelf': '02', 'space': 'a', 'movie_id': null},
	8: { 'shelf': '02', 'space': 'b', 'movie_id': null},
	9: { 'shelf': '02', 'space': 'c', 'movie_id': null},
	10: { 'shelf': '02', 'space': 'd', 'movie_id': null},
	11: { 'shelf': '02', 'space': 'e', 'movie_id': null},
	12: { 'shelf': '02', 'space': 'f', 'movie_id': null},
	13: { 'shelf': '03', 'space': 'a', 'movie_id': null},
	14: { 'shelf': '03', 'space': 'b', 'movie_id': null},
	15: { 'shelf': '03', 'space': 'c', 'movie_id': null},
	16: { 'shelf': '03', 'space': 'd', 'movie_id': null},
	17: { 'shelf': '03', 'space': 'e', 'movie_id': null},
	18: { 'shelf': '03', 'space': 'f', 'movie_id': null},
	19: { 'shelf': '04', 'space': 'a', 'movie_id': null},
	20: { 'shelf': '04', 'space': 'b', 'movie_id': null},
	21: { 'shelf': '04', 'space': 'c', 'movie_id': null},
	22: { 'shelf': '04', 'space': 'd', 'movie_id': null},
	23: { 'shelf': '04', 'space': 'e', 'movie_id': null},
	24: { 'shelf': '04', 'space': 'f', 'movie_id': null},
	25: { 'shelf': '05', 'space': 'a', 'movie_id': null},
	26: { 'shelf': '05', 'space': 'b', 'movie_id': null},
	27: { 'shelf': '05', 'space': 'c', 'movie_id': null},
	28: { 'shelf': '05', 'space': 'd', 'movie_id': null},
	29: { 'shelf': '05', 'space': 'e', 'movie_id': null},
	30: { 'shelf': '05', 'space': 'f', 'movie_id': null},
	31: { 'shelf': '06', 'space': 'a', 'movie_id': null},
	32: { 'shelf': '06', 'space': 'b', 'movie_id': null},
	33: { 'shelf': '06', 'space': 'c', 'movie_id': null},
	34: { 'shelf': '06', 'space': 'd', 'movie_id': null},
	35: { 'shelf': '06', 'space': 'e', 'movie_id': null},
	36: { 'shelf': '06', 'space': 'f', 'movie_id': null},
}

var stocked_count: int = 0

func _ready() -> void:
	# init shelf label
	$Genre.text = shelf_genre
	$Genre.modulate = m.genre_colors[shelf_genre]
	$Genre.add_theme_color_override('font_color', m.genre_colors[shelf_genre])
	print('shelf_genre:', shelf_genre, ', color:', m.genre_colors[shelf_genre])
	$Count.text = '0/36'
	$Count.add_theme_color_override('font_color', m.genre_colors[shelf_genre])
	# init stocked movies
	for movie_id in m.inventory.keys():
		attempt_add_movie(movie_id)

func stock_movie(movie_id: String):
	attempt_add_movie(movie_id)

func attempt_add_movie(movie_id: String):
	var movie = m.inventory[movie_id]
	if movie.status == 'STOCKED' and movie.genre == shelf_genre:
		stocked_count += 1
		if stocked_count > 36:
			return
		$Count.text = str(stocked_count) + '/36'
		var shelf_space: Dictionary = spaces[stocked_count]
		shelf_space.movie_id = movie_id
		var shelf_node: TextureRect = get_node(shelf_space.shelf + '/' + shelf_space.space)
		shelf_node.texture = load('res://movies/covers/%s.png' % movie_id)
		shelf_node.show()
