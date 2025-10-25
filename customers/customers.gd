extends Node

var customers: Dictionary = {
	'Ari W': {
		'fave_genre': 'HORROR',
		'friendship_level': 0,
		'extrovert': true
	},
}

func generate_customer(returning_new_movie: bool) -> Dictionary:
	var customer: Dictionary = {
		'returning_new_movie': returning_new_movie
	}
	return customer
