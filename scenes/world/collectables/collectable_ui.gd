extends Control

@onready var label = $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	var collected = "0"
	var target = str(GameController.missions[GameController.missionIndex].collect.red).pad_decimals(0)
	label.text = collected + " / " + target
	EventController.connect("collectable_collected", on_event_collectable_collected)
	
func on_event_collectable_collected(value: int) -> void:
	var collected = str(value)
	var target = str(GameController.missions[GameController.missionIndex].collect.red).pad_decimals(0)
	label.text = collected + " / " + target
