extends Node


# Called when the node enters the scene tree for the first time.
var total_collectables: int = 0

func collectable_collected(value: int):
	total_collectables += value
	EventController.emit_signal("collectable_collected", total_collectables)
	
