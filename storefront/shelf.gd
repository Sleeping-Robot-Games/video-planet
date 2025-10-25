extends Sprite2D

@export_enum('HORROR', 'SCI-FI', 'ROMANCE', 'COMEDY') var genre: String

func _ready() -> void:
	print('genre: ', genre)
