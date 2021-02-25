extends Node2D

func _ready():
	preload("GGTests.gd").new().run()
	yield(get_tree().create_timer(.2), "timeout") # workaround for missing output
	get_tree().quit()
