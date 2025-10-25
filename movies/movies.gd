extends Node

var genre_colors: Dictionary = {
	'HORROR': Color('#ff0000'),
	'SCI-FI': Color('#0000ff'),
	'ROMANCE': Color('#ff00ff'),
	'COMEDY': Color('#ff5600')
}

var status_colors: Dictionary = {
	'STOCKED': Color('#00ff00'),
	'BACKLOG': Color("f2005fff"),
	'CHECKED OUT': Color("4022baff")
}

var inventory: Dictionary = {
	'001': {
		'title': 'FISH LIPS',
		'genre': 'HORROR',
		'status': 'STOCKED',
		'location': 'ON SHELF',
		'reviews': [
			{
				'user': '@JDAWG79',
				'content': 'JERK SHERKS YO!! LIT',
				'is_positive': true
			}
		]
	},
	'002': {
		'title': 'TBD',
		'genre': 'HORROR',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'003': {
		'title': 'TBD',
		'genre': 'HORROR',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'004': {
		'title': 'TBD',
		'genre': 'HORROR',
		'status': 'CHECKED OUT',
		'location': 'ARI W',
		'reviews': []
	},
	'005': {
		'title': 'TBD',
		'genre': 'SCI-FI',
		'status': 'CHECKED OUT',
		'location': 'JOAN G',
		'reviews': []
	},
	'006': {
		'title': 'TBD',
		'genre': 'SCI-FI',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'007': {
		'title': 'TBD',
		'genre': 'SCI-FI',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'008': {
		'title': 'TBD',
		'genre': 'SCI-FI',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'009': {
		'title': 'THE BOATNOOK',
		'genre': 'ROMANCE',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'010': {
		'title': 'TBD',
		'genre': 'ROMANCE',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'011': {
		'title': 'TBD',
		'genre': 'ROMANCE',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'012': {
		'title': 'TBD',
		'genre': 'ROMANCE',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'013': {
		'title': 'TBD',
		'genre': 'COMEDY',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'014': {
		'title': 'TBD',
		'genre': 'COMEDY',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'015': {
		'title': 'TBD',
		'genre': 'COMEDY',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	},
	'016': {
		'title': 'TBD',
		'genre': 'COMEDY',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': []
	}
}

func generate_movie() -> Dictionary:
	var movie: Dictionary = {
		'title': 'TBD',
		'genre': 'TBD',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': [],
	}
	# title
	
	
	return movie
