extends Node

## Personality-based dialog system for customer interactions
## Defines small talk, persuasion responses, and personality characteristics

const PERSONALITIES = {
	"PICKY": {
		"description": "Detail-oriented, hard to please, high standards",
		"small_talk": [
			"I've been reading a lot lately. Really opens your mind.",
			"Quality over quantity, that's my philosophy.",
			"I'm quite particular about what I spend my time on.",
			"I like to do my research before making decisions.",
			"Most things don't live up to the hype, in my experience.",
			"Details matter. The little things make all the difference.",
			"I appreciate when someone really knows their craft.",
			"I've developed pretty refined tastes over the years.",
			"Mediocrity is everywhere. I prefer excellence.",
			"I always look for substance, not just flash.",
			"People settle for 'good enough' too easily these days.",
			"I know what I like, and I'm not afraid to be selective.",
			"There's a right way and a wrong way to do things.",
			"First impressions matter a lot to me.",
			"I can tell when something's poorly made.",
		],
		"persuasion_correct": [
			"This one's really well-crafted",
			"The quality on this is exceptional",
			"This has substance - not just style",
			"This one's gotten consistently strong reviews",
			"The attention to detail in this is impressive",
			"The craftsmanship here is outstanding",
			"This meets very high standards",
			"The execution on this is flawless",
			"This is a cut above the rest, quality-wise",
			"The production value is top-notch",
			"This has real depth and nuance",
			"The attention to detail is remarkable",
			"This stands up to scrutiny",
			"A sophisticated choice for discerning taste",
			"This exemplifies excellence in the genre",
		],
		"persuasion_wrong": [
			"It's super fun!",
			"Everyone's talking about it!",
			"It's a blast to watch!",
			"You'll love it, trust me!",
			"It's the hottest one right now!",
			"So popular right now!",
			"Everybody's watching this!",
			"It's trending everywhere!",
			"You can't go wrong with this!",
			"Just trust me on this!",
		]
	},
	"CHEERFUL": {
		"description": "Upbeat, positive, easy to excite",
		"small_talk": [
			"Oh man, I'm SO pumped to be here!",
			"I love discovering new things! This is exciting!",
			"Today's been GREAT so far!",
			"I can't wait to see what you've got!",
			"This place has such good vibes!",
			"I'm always up for trying something new!",
			"Life's too short to not enjoy yourself, right?",
			"I'm feeling REALLY good about this!",
			"Everything just seems to be going well today!",
			"I love the energy in here!",
			"I woke up in such a good mood this morning!",
			"You know what? I'm just happy to be out and about!",
			"There's so much to look forward to!",
			"I just love days like this!",
			"I'm always down for a good time!",
		],
		"persuasion_correct": [
			"This one's a blast! You'll have so much fun!",
			"Oh you're gonna LOVE this one!",
			"This is so exciting - perfect choice!",
			"This one's amazing! Such a good time!",
			"You're going to have the best time with this!",
			"This is an absolute thrill ride!",
			"You'll be smiling the whole time!",
			"This is pure entertainment!",
			"Get ready for a great experience!",
			"This one's a real crowd-pleaser!",
			"You're in for such a treat!",
			"This is gonna blow you away!",
			"Prepare to be wowed!",
			"This is exactly what you need!",
			"Trust me, you'll be telling everyone about this!",
		],
		"persuasion_wrong": [
			"It's very subtle and understated",
			"This one's a slow burn",
			"The pacing is deliberately methodical",
			"It's quite dense and complex",
			"This requires careful attention to detail",
			"It's contemplative and quiet",
			"A measured, thoughtful approach",
			"The tone is restrained",
			"It demands patience",
			"Not for everyone, honestly",
		]
	},
	"GRUMPY": {
		"description": "Negative, pessimistic, hard to impress",
		"small_talk": [
			"Most things don't live up to expectations...",
			"I've been disappointed before, so I'm careful.",
			"People tend to exaggerate. I need proof.",
			"I don't buy into hype easily.",
			"Everyone has an agenda these days.",
			"I trust my own judgment more than others'.",
			"Seems like everything's overrated lately.",
			"I've learned to keep my expectations low.",
			"Talk is cheap. Results are what matter.",
			"I'm not easily impressed, honestly.",
			"It's been a long day. Long week, actually.",
			"Nothing ever goes quite right, does it?",
			"I'm tired of getting my hopes up for nothing.",
			"Standards have really gone downhill lately.",
			"I've seen it all before. Nothing surprises me anymore.",
		],
		"persuasion_correct": [
			"I've checked this one out myself - it delivers",
			"This one actually lives up to expectations",
			"I wouldn't recommend it if it wasn't solid",
			"No hype - this one's genuinely good",
			"The evidence speaks for itself with this one",
			"I've seen the proof - this one holds up",
			"Not gonna sugarcoat it - this is legitimate",
			"Against my better judgment, this is actually decent",
			"I'm skeptical by nature, but this earns it",
			"The track record on this speaks volumes",
			"Results don't lie with this one",
			"I did my homework - this checks out",
			"Rare to say, but this delivers what it promises",
			"I'm not easily convinced, but this convinced me",
			"The facts back this up, plain and simple",
		],
		"persuasion_wrong": [
			"Everyone's raving about it!",
			"It's trending right now!",
			"You'll definitely love it!",
			"Trust me on this one!",
			"It's super popular!",
			"All the buzz is about this!",
			"People can't stop talking about it!",
			"It's the talk of the town!",
			"You're gonna love it for sure!",
			"This is what everyone wants!",
		]
	},
	"CHATTY": {
		"description": "Talkative, friendly, people-oriented",
		"small_talk": [
			"How's your day been? Mine's been lovely!",
			"I love chatting with new people!",
			"You seem friendly! How long have you worked here?",
			"My friends told me about this place!",
			"There's nothing better than a good conversation.",
			"I always remember the friendly faces.",
			"Do you enjoy working here? You seem happy!",
			"I love getting to know the local spots.",
			"Connection is important, don't you think?",
			"You have such a welcoming energy!",
			"I was just telling my neighbor about this store!",
			"Oh, I could talk for hours, honestly.",
			"My cousin recommended this place. Do you know them?",
			"I'm all about supporting local businesses!",
			"I love a place where people actually care!",
		],
		"persuasion_correct": [
			"I think you'd really connect with this one",
			"Based on our chat, this feels right for you",
			"I'd love to hear what you think about this!",
			"This one feels like it matches your vibe",
			"I have a good feeling about this for you",
			"Getting to know you, I think you'll enjoy this",
			"Something about you says this is the one",
			"I can just tell this will resonate with you",
			"We've had such a nice chat - this fits you perfectly",
			"I'd be excited to hear your thoughts next time!",
			"You strike me as someone who'd appreciate this",
			"I'm getting the sense this is exactly what you need",
			"Call it intuition, but this feels like your speed",
			"You remind me of someone who loved this",
			"I have a knack for matching people - trust me on this!",
		],
		"persuasion_wrong": [
			"The technical specs are impressive",
			"Statistically, this is the top choice",
			"The metrics on this are excellent",
			"Objectively speaking, this is superior",
			"The data clearly shows this is best",
			"The numbers don't lie on this one",
			"Analytically, this ranks highest",
			"By all measurable standards, this wins",
			"The performance metrics are unmatched",
			"Quantifiably the optimal selection",
		]
	},
	"CHILL": {
		"description": "Relaxed, easygoing, low-maintenance",
		"small_talk": [
			"Hey, how's it going?",
			"Another day, another rental.",
			"You know how it is - need something for tonight.",
			"Business good today?",
			"I'm back again. This is becoming a habit.",
			"Same old, same old. Can't complain though.",
			"Just doing my usual routine.",
			"Nothing exciting, just looking for something decent.",
			"Keeping it simple today.",
			"The usual for me - just browsing.",
			"Not much new with me. You?",
			"Just taking it easy, you know?",
			"No rush. Just seeing what's available.",
			"Pretty standard week so far.",
			"Can't complain. Could be worse.",
		],
		"persuasion_correct": [
			"This one's solid - good choice",
			"Yeah, this should work for you",
			"A lot of folks have liked this one",
			"This is a reliable pick",
			"Can't go wrong with this one",
			"Pretty safe bet with this",
			"This one won't let you down",
			"Seems like a good fit",
			"Yeah, I'd go with this",
			"Solid choice, no complaints",
			"This should do the trick",
			"Can't really go wrong here",
			"Decent option, yeah",
			"This one's a good call",
			"Safe and reliable - my kind of pick",
		],
		"persuasion_wrong": [
			"THIS IS THE MOST AMAZING THING EVER!!!",
			"Honestly, it's kind of terrible",
			"I haven't looked at it but whatever",
			"Just pick anything, doesn't matter",
			"Maybe? I don't know, who cares",
			"OMG YOU HAVE TO GET THIS RIGHT NOW!!!",
			"This will LITERALLY change your life!",
			"I mean... it exists, I guess?",
			"Whatever floats your boat, I suppose",
			"Meh. Take it or leave it",
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
