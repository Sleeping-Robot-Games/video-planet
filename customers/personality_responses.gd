extends Node

## Personality-based dialog system for customer interactions
## Defines small talk, persuasion responses, and personality characteristics

const PERSONALITIES = {
	"CRITIC": {
		"description": "Analytical, values expertise and technical details",
		"small_talk": [
			"I've been analyzing film theory lately... fascinating stuff.",
			"The cinematography in modern films has really declined, don't you think?",
			"I'm very particular about pacing and structure in storytelling.",
			"I always read at least three reviews before watching anything.",
			"The use of color grading in recent films is quite interesting to study.",
		],
		"persuasion_correct": [
			"This film has exceptional cinematography",
			"The director is known for their technical mastery",
			"Critics have praised its sophisticated narrative structure",
			"This one won awards for its screenplay",
			"The film studies community considers this a masterpiece",
		],
		"persuasion_wrong": [
			"It's super fun!",
			"Everyone's talking about it!",
			"It's a blast to watch!",
			"You'll love it, trust me!",
			"It's the hottest movie right now!",
		]
	},
	"ENTHUSIAST": {
		"description": "Excitable, values fun and excitement",
		"small_talk": [
			"I LOVE movies! I watch like three a week!",
			"Movie nights are the BEST! So excited to be here!",
			"Oh man, I can't wait to find something amazing!",
			"This store is SO cool! I'm gonna be a regular for sure!",
			"I'm in such a good mood today, perfect for picking a movie!",
		],
		"persuasion_correct": [
			"This one's a blast! You'll have so much fun!",
			"It's super exciting from start to finish!",
			"Everyone I know loved it!",
			"This is the most entertaining one we have!",
			"You're going to have an amazing time with this!",
		],
		"persuasion_wrong": [
			"The director uses subtle symbolism throughout",
			"It's a slow-burn character study",
			"The pacing is deliberately methodical",
			"It has complex narrative layers to analyze",
			"Critics praised its understated approach",
		]
	},
	"SKEPTIC": {
		"description": "Cynical, values honesty and proof",
		"small_talk": [
			"Most movies are overhyped these days...",
			"I've been burned by bad recommendations before.",
			"Marketing can't fool me. I know what's actually good.",
			"I don't trust ratings. Everyone's got an agenda.",
			"People are way too easy to please with movies nowadays.",
		],
		"persuasion_correct": [
			"I've seen this one myself. It's genuinely good.",
			"The reviews are consistent - not just hype",
			"I wouldn't recommend it if I didn't believe in it",
			"This one delivers exactly what it promises",
			"No marketing nonsense - this one's the real deal",
		],
		"persuasion_wrong": [
			"Everyone's raving about it!",
			"It's trending right now!",
			"You'll definitely love it!",
			"Trust me on this one!",
			"It's super popular!",
		]
	},
	"SOCIALITE": {
		"description": "Chatty, values personal connection",
		"small_talk": [
			"How's your day going? Mine's been pretty great!",
			"I love getting to know the people who work here.",
			"My friends keep telling me about this place!",
			"Do you work here often? I'd love to hear your recommendations!",
			"There's something special about a good conversation, you know?",
		],
		"persuasion_correct": [
			"I personally think you'd really enjoy this one",
			"Based on what you told me, this feels like a perfect fit",
			"I'd love to hear what you think about it next time",
			"This one made me think of you when you mentioned your taste",
			"I have a good feeling about this one for you",
		],
		"persuasion_wrong": [
			"The technical specs are impressive",
			"It's statistically the highest rated",
			"The production value is objectively superior",
			"This one has the best metrics",
			"The data shows this is the optimal choice",
		]
	},
	"REGULAR": {
		"description": "Balanced, familiar and easygoing",
		"small_talk": [
			"Good to see you again. How's business?",
			"I'm back for another movie night.",
			"You know how it is - Friday night, need something to watch.",
			"I've been coming here for a while now. Good spot.",
			"Another week, another rental. Let's see what you got.",
		],
		"persuasion_correct": [
			"This one just came in - it's solid",
			"A lot of people have enjoyed this one",
			"This is a reliable choice for what you're looking for",
			"I think this hits what you're after",
			"This one's been pretty well-received",
		],
		"persuasion_wrong": [
			"You'll LOVE IT SO MUCH!!!",
			"This is literally the most boring one we have",
			"I haven't seen it but whatever",
			"Just take whatever, I don't care",
			"This one's probably fine I guess, maybe, who knows",
		]
	}
}

## Get small talk dialog for a personality type
func get_small_talk(personality_type: String) -> String:
	if not PERSONALITIES.has(personality_type):
		return "Hi there!"
	return PERSONALITIES[personality_type].small_talk.pick_random()

## Get the correct persuasion response for a personality type
func get_correct_response(personality_type: String) -> String:
	if not PERSONALITIES.has(personality_type):
		return "I think you'll like it"
	return PERSONALITIES[personality_type].persuasion_correct.pick_random()

## Get wrong persuasion responses for a personality type
## Returns an array of 2 wrong responses from other personality types
func get_wrong_responses(personality_type: String) -> Array:
	var wrong_responses = []

	# Collect wrong responses from the personality's own wrong pool
	if PERSONALITIES.has(personality_type):
		wrong_responses.append_array(PERSONALITIES[personality_type].persuasion_wrong)

	# Also grab some correct responses from OTHER personalities (which would be wrong for this one)
	for other_personality in PERSONALITIES.keys():
		if other_personality != personality_type:
			wrong_responses.append_array(PERSONALITIES[other_personality].persuasion_correct)

	# Shuffle and return 2 random wrong responses
	wrong_responses.shuffle()
	return [wrong_responses[0], wrong_responses[1]]

## Get all 3 persuasion options (1 correct, 2 wrong) in random order
## Returns Dictionary with 'options' array and 'correct_index' int
func get_persuasion_options(personality_type: String) -> Dictionary:
	var correct = get_correct_response(personality_type)
	var wrong = get_wrong_responses(personality_type)

	var all_options = [correct, wrong[0], wrong[1]]
	var correct_index = 0  # Track where the correct answer ends up

	# Shuffle the options
	all_options.shuffle()

	# Find the new index of the correct answer
	correct_index = all_options.find(correct)

	return {
		"options": all_options,
		"correct_index": correct_index
	}

## Get a random personality type
func get_random_personality() -> String:
	return PERSONALITIES.keys().pick_random()
