extends AudioStreamPlayer

var music = [
	"pixel.mp3",
	"space.mp3",
	"melomania.mp3",
	"standard.mp3",
]

#var last = null

func _ready():
	randomize()
	rand_aydio()

func rand_aydio():
	#var mus = music.duplicate(true)
	#for i in range(music.size()):
	#	if last == music[i]:
	#		mus = mus.erase(i)
	
	#last = mus[int(round(rand_range(-0.4, float(mus.size())-0.6)))]
	
	stream = load("res://audios/music//"+music[int(round(rand_range(-0.4, float(music.size())-0.6)))])
	play()

