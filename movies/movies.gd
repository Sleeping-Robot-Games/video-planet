extends Node

signal rented_movie_selected(movie_id: String, customer_name: String)

var genre_colors: Dictionary = {
	'HORROR': Color('#ff0000'),
	'SCI-FI': Color("1854ffff"),
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

#func _ready():
	#for _i in range(1, 50):
		#var movie = generate_movie('BACKLOG')
		#print('[%s] %s' % [movie.genre, movie.title])

func generate_movie(status: String, customer: String = '') -> Dictionary:
	var movie: Dictionary = {
		'title': 'TBD',
		'genre': 'TBD',
		'status': 'BACKLOG',
		'location': 'NEEDS REWIND',
		'reviews': [],
	}
	
	# genre
	movie.genre = ['HORROR', 'SCI-FI', 'ROMANCE', 'COMEDY'].pick_random()
	
	# title
	match movie.genre:
		'HORROR':
			movie.title = generate_horror_title()
		'SCI-FI':
			movie.title = generate_scifi_title()
		'ROMANCE':
			movie.title = generate_romance_title()
		'COMEDY':
			movie.title = generate_comedy_title()
	
	
	# status
	movie.status = status
	match status:
		'STOCKED':
			movie.location = 'ON SHELF'
		'BACKLOG':
			movie.location = 'NEEDS REWIND'
		'CHECKED OUT':
			movie.location = customer
	
	return movie

## HORROR TITLES -----

func generate_horror_title() -> String:
	var template: String = horror_templates.pick_random()

	# Replace placeholders with random words
	template = template.replace("{adj}", horror_adjectives.pick_random())
	template = template.replace("{noun}", horror_nouns.pick_random())
	template = template.replace("{noun2}", horror_nouns.pick_random())
	template = template.replace("{location}", horror_locations.pick_random())
	template = template.replace("{location2}", horror_locations.pick_random())
	template = template.replace("{verb}", horror_verbs.pick_random())

	return template

var horror_templates: Array = [
	"{adj} {noun}",
	"The {noun} of {noun2}",
	"{noun} from the {location}",
	"Night of the {adj} {noun}",
	"The {adj} {location}",
	"{noun} {verb}",
	"{location} {verb}",
	"{adj} {noun}s of {location}",
	"I'm at the Combination {location} / {location2}"
]

var horror_adjectives: Array = [
	"Bloody", "Dark", "Evil", "Cursed", "Haunted", "Demonic", "Wicked",
	"Twisted", "Sinister", "Creeping", "Lurking", "Dead", "Undead",
	"Rotting", "Ancient", "Forbidden", "Lost", "Deadly", "Savage",
	"Screaming", "Silent", "Shadowy", "Vengeful", "Nightmare", "Toxic",
	"Running", "Deep", "Sinking", "Pushing", "Squelching", "Squanching",
	"Popping", "Snarky", "Hecking", "Slimy", "Oozing", "Lonely", "Blind",
	"Neglected", "Hungry", "Starving", "Drooling", "Watching", "Stalking",
	"Hash-slinging", "Red"
]

var horror_nouns: Array = [
	"Zombie", "Ghost", "Demon", "Witch", "Vampire", "Werewolf", "Beast",
	"Creature", "Monster", "Specter", "Shadow", "Skull", "Brain", "Blood",
	"Flesh", "Crypt", "Tomb", "Grave", "Corpse", "Bone", "Soul", "Spirit",
	"Parasite", "Infection", "Curse", "Doll", "Clown", "Spider", "Raven",
	"Stump", "Bounce House", "Pizza", "Lich", "Hatchling", "Spikes", "Chumba",
	"Snicker", "Snack", "Slasher"
]

var horror_locations: Array = [
	"Crypt", "Cemetery", "Mansion", "Basement", "Attic", "Woods", "Swamp",
	"Asylum", "Hospital", "School", "Church", "Hell", "Heck", "Darkness", "Shadows",
	"Void", "Abyss", "Tunnel", "Cave", "Island", "Village", "Laboratory",
	"Outer Space"
]

var horror_verbs: Array = [
	"Kills", "Stalks", "Haunts", "Screams", "Watches", "Feeds", "Rises",
	"Returns", "Awakens", "Strikes", "Consumes", "Possesses", "Lurks", "Neglects"
]


## SCI-FI TITLES -----

func generate_scifi_title() -> String:
	var template: String = scifi_templates.pick_random()

	# Replace placeholders with random words
	template = template.replace("{adj}", scifi_adjectives.pick_random())
	template = template.replace("{noun}", scifi_nouns.pick_random())
	template = template.replace("{planet}", scifi_planets.pick_random())
	template = template.replace("{number}", scifi_numbers.pick_random())
	template = template.replace("{vehicle}", scifi_vehicles.pick_random())
	template = template.replace("{codename}", scifi_codenames.pick_random())
	template = template.replace("{job}", scifi_jobs.pick_random())
	template = template.replace("{location}", scifi_locations.pick_random())
	
	return template


var scifi_templates: Array = [
	"The {adj} {noun}",
	"{planet} {number}",
	"Attack of the {adj} {noun}",
	"{noun} from {planet}",
	"The Last {noun}",
	"{adj} {vehicle} to {planet}",
	"Operation: {codename}",
	"Project {noun}",
    "{job} of the {location}"
]

var scifi_adjectives: Array = [
	"Quantum", "Cosmic", "Robotic", "Digital", "Cyber", "Atomic",
	"Neural", "Genetic", "Bionic", "Stellar", "Galactic", "Synthetic",
	"Mechanical", "Temporal", "Dimensional", "Interstellar", "Binary",
	"Artificial", "Hyper", "Nano", "Virtual", "Chrome", "Solar", "Battery-operated"
]

var scifi_nouns: Array = [
	"Android", "Robot", "AI", "Matrix", "Cyborg", "Clone", "Hologram",
	"Algorithm", "Mainframe", "Singularity", "Protocol", "Interface",
	"Consciousness", "Network", "Virus", "Signal", "Upload", "Download",
	"Simulation", "Database", "Firewall", "Code", "Neuron", "Beep Boop"
]

var scifi_planets: Array = [
	"Alpha", "Beta", "Gamma", "Delta", "Omega", "Nova", "Proxima",
	"Nexus", "Vector", "Zero", "Prime", "Centauri", "Helios", "Chronos",
	"Atlas", "Titan", "Europa", "Io", "Phobos", "Deimos"
]

var scifi_numbers: Array = [
	"X", "Zero", "Prime", "Infinite", "3000", "9000", "Alpha", "Omega",
	"XIII", "VII", "V2", "MK-II", "2.0", "Beta", "1984", "2525", "3001",
	"Mark 5", "Series 7", "Type-X", "Gen-3", "Lambda", "Sigma", "Z-1",
	"0451", "One", "Ten", "100", "Binary", "XR", "XJ-9", "K-7",
	"Delta-4", "Gamma-6", "Unit 01", "Protocol 7", "Version 2.4"
]

var scifi_vehicles: Array = [
	"Shuttle", "Starship", "Cruiser", "Pod", "Vessel", "Carrier",
	"Transport", "Freighter", "Rocket", "Ship", "Module", "Probe"
]

var scifi_jobs: Array = [
	"Commander", "Pilot", "Engineer", "Navigator", "Captain", "Agent",
	"Operative", "Technician", "Officer", "Specialist", "Explorer"
]

var scifi_locations: Array = [
	"Deep Space", "Outer Rim", "Colony", "Station", "Base", "Lab",
	"Outpost", "Sector", "Quadrant", "Zone", "Grid", "Network"
]

var scifi_codenames: Array = [
	"Starburst", "Black Hole", "Supernova", "Eclipse", "Genesis",
	"Omega", "Infinity", "Nebula", "Starfall", "Exodus", "Horizon"
]


## ROMANCE TITLES -----

func generate_romance_title() -> String:
	var template: String = romance_templates.pick_random()

	# Replace placeholders with random words
	template = template.replace("{adj}", romance_adjectives.pick_random())
	template = template.replace("{noun}", romance_nouns.pick_random())
	template = template.replace("{noun2}", romance_nouns.pick_random())
	template = template.replace("{verb}", romance_verbs.pick_random())
	template = template.replace("{profession}", romance_professions.pick_random())
	template = template.replace("{season}", romance_seasons.pick_random())
	template = template.replace("{location}", romance_locations.pick_random())
	
	
	return template


var romance_templates: Array = [
	"{adj} {noun}",
	"The {noun}'s {noun2}",
	"{verb} by the {noun}",
	"{verb} in {location}",
	"The {adj} {profession}",
	"My {adj} {noun}",
	"{verb} with a {profession}",
	"{season} {noun}",
	"A {noun} in {location}",
	"The {profession}'s {adj} {noun}",
	"{verb} Under the {noun}",
    "{adj} {location} {noun}"
]

var romance_adjectives: Array = [
	"Sweet", "Forever", "Love-struck", "Passionate", "Secret",
	"Forbidden", "Stolen", "Wild", "Tender", "Gentle", "Devoted",
	"Enchanted", "Hopeless", "Reckless", "Moonlit", "Destined",
	"Perfect", "Reluctant", "Unexpected", "Accidental", "Midnight",
	"Summer", "Winter", "Spring", "Autumn", "Beautiful", "Charming"
]

var romance_nouns: Array = [
	"Love", "Heart", "Kiss", "Promise", "Destiny", "Romance",
	"Affair", "Embrace", "Secret", "Passion", "Dream", "Dance",
	"Wedding", "Marriage", "Date", "Proposal", "Letter", "Vacation",
	"Moment", "Sunset", "Sunrise", "Moon", "Star", "Rose", "Garden"
]

var romance_verbs: Array = [
	"Dancing", "Falling", "Kissing", "Loving", "Meeting", "Dreaming",
	"Swooning", "Enchanted", "Married", "Engaged", "Romancing",
	"Courting", "Dating", "Eloping", "Cherishing", "Yearning"
]

var romance_locations: Array = [
	"Paris", "Venice", "Rome", "Manhattan", "London", "Tuscany",
	"Paradise", "Heaven", "the Beach", "the Lake", "the Vineyard",
	"the Castle", "the Estate", "the Garden", "the Countryside",
	"the Villa", "the Chateau", "the Coast", "the Islands"
]

var romance_professions: Array = [
	"Doctor", "Duke", "Dancer", "CEO", "Singer", "Princess",
	"Artist", "Writer", "Chef", "Rancher", "Cowboy", "Pilot",
	"Surgeon", "Count", "Earl", "Lord", "Lady", "Duchess",
	"Musician", "Designer", "Architect", "Veteran"
]

var romance_seasons: Array = [
	"Summer", "Winter", "Spring", "Autumn", "Holiday", "Christmas",
	"Valentine", "New Year's", "Midnight", "Weekend", "Forever"
]

## COMEDY TITLES -----

func generate_comedy_title() -> String:
	var template: String = comedy_templates.pick_random()

	# Replace placeholders with random words
	template = template.replace("{adj}", comedy_adjectives.pick_random())
	template = template.replace("{noun}", comedy_nouns.pick_random())
	template = template.replace("{noun2}", comedy_nouns.pick_random())
	template = template.replace("{profession}", comedy_professions.pick_random())
	template = template.replace("{location}", comedy_locations.pick_random())
	template = template.replace("{verb}", comedy_verbs.pick_random())
	template = template.replace("{verb2}", comedy_verbs.pick_random())
	template = template.replace("{name}", comedy_names.pick_random())
	template = template.replace("{number}", comedy_numbers.pick_random())

	return template


var comedy_templates: Array = [
	"The {adj} {noun}",
	"My {adj} {noun}",
	"How to {verb} a {noun}",
	"Dude, Where's My {noun}",
	"{profession}'s Day {location}",
	"{verb} with my {noun}",
	"The {noun} {verb}s Back",
	"National {noun}",
	"{number} {noun}s and a {noun2}",
	"Don't Tell Mom the {noun} is {adj}",
	"Honey, I {verb} the {noun}",
	"{verb} Academy",
	"The {adj} {profession}",
	"Weekend at {name}'s",
	"{name} Takes {location}",
	"{verb} and {verb2}",
    "Who {verb} my {noun}?"
]

var comedy_adjectives: Array = [
	"Crazy", "Wacky", "Wild", "Stupid", "Ridiculous", "Hilarious",
	"Awkward", "Embarrassing", "Accidental", "Terrible", "Amazing",
	"Incredible", "Outrageous", "Desperate", "Hopeless", "Confused",
	"Clueless", "Bumbling", "Goofy", "Ditzy", "Zany", "Madcap", "Stinky"
]

var comedy_nouns: Array = [
	"Party", "Wedding", "Date", "Vacation", "Road Trip", "Family",
	"Babysitter", "Neighbor", "Boss", "Job", "Dog", "Cat", "Pet",
	"House", "Car", "School", "College", "Reunion", "Birthday",
	"Dentist", "Doctor", "Gym", "Restaurant", "Hotel", "Cruise",
	"Clown", "Cop", "Spy", "Ninja", "Robot", "Alien", "President",
	"Monkey"
]

var comedy_verbs: Array = [
	"Train", "Lose", "Find", "Break", "Fix", "Destroy", "Save",
	"Survive", "Escape", "Crash", "Fail", "Win", "Meet", "Date",
	"Marry", "Divorce", "Babysit", "Work", "Party", "Dance",
	"Cook", "Drive", "Fight", "Chase"
]

var comedy_locations: Array = [
	"Off", "in Vegas", "at the Beach", "in Paris", "at Work",
	"at School", "in Space", "at Camp", "in the City",
	"at the Mall", "in Hawaii", "at Home", "Downtown"
]

var comedy_professions: Array = [
	"Dad", "Mom", "Grandpa", "Grandma", "Uncle", "Teacher",
	"Lawyer", "Doctor", "Cop", "Nurse", "Nanny", "Chef",
	"Lifeguard", "Librarian", "Principal", "President"
]

var comedy_numbers: Array = [
	"Two", "Three", "Four", "Five", "Six", "Seven", "Eight",
	"Nine", "Ten", "Twelve", "Hundred"
]

var comedy_names: Array = [
	"Bernie", "Bob", "Bill", "Ted", "Dave", "Steve", "Kevin",
	"Stuart", "Larry", "Barry", "Jerry", "Tommy", "Jimmy",
	"Timmy", "Bobby", "Billy", "Joey", "Betty", "Mary", "Sally",
	"Lucy", "Molly", "Katie", "Annie", "Penny", "Mindy", "Wendy",
	"Debbie", "Susie", "Jenny", "Judy", "Nancy", "Polly", "Peggy",
	"Maggie", "Roxie", "Trixie", "Fanny", "Dottie", "Lizzie"
]
