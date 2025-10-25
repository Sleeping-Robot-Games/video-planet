extends Node

var customers: Dictionary = {
	'Ari W': {
		'fave_genre': 'HORROR', # other options 
		'friendship_level': 0,
		'extrovert': true,
		'goal': 'rent', # other option is 'return'
		
	},
}

func generate_customer(returning_new_movie: bool) -> Dictionary:
	var customer: Dictionary = {
		'returning_new_movie': returning_new_movie
	}
	return customer
