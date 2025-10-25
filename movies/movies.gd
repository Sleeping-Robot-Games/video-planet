extends Node

var genre_colors: Dictionary = {
	'HORROR': Color('#ff0000'),
	'SCI-FI': Color('#0000ff'),
	'ROMANCE': Color('#ff00ff'),
	'COMEDY': Color('#ff5600')
}

var status_colors: Dictionary = {
	'STOCKED': Color('#00ff00'),
	'UNSTOCKED': Color("f2005fff"),
	'CHECKED OUT': Color("4022baff")
}

var inventory: Dictionary = {
	'001': {
		'title': 'FISH LIPS',
		'genre': 'HORROR',
		'status': 'STOCKED',
		'location': 'HOR-SH-02',
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
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'003': {
		'title': 'TBD',
		'genre': 'HORROR',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
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
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'007': {
		'title': 'TBD',
		'genre': 'SCI-FI',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'008': {
		'title': 'TBD',
		'genre': 'SCI-FI',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'009': {
		'title': 'THE BOATNOOK',
		'genre': 'ROMANCE',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'010': {
		'title': 'TBD',
		'genre': 'ROMANCE',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'011': {
		'title': 'TBD',
		'genre': 'ROMANCE',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'012': {
		'title': 'TBD',
		'genre': 'ROMANCE',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'013': {
		'title': 'TBD',
		'genre': 'COMEDY',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'014': {
		'title': 'TBD',
		'genre': 'COMEDY',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'015': {
		'title': 'TBD',
		'genre': 'COMEDY',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	},
	'016': {
		'title': 'TBD',
		'genre': 'COMEDY',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': []
	}
}

func generate_movie() -> Dictionary:
	var movie: Dictionary = {
		'title': 'TBD',
		'genre': 'TBD',
		'status': 'UNSTOCKED',
		'location': 'REWIND-DESK',
		'reviews': [],
	}
	# title
	
	
	return movie
