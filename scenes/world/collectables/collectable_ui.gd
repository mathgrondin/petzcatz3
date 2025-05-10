extends Control

@onready var label = $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	EventController.connect("collectable_collected", on_event_collectable_collected)
	
func on_event_collectable_collected(value: int) -> void:
	label.text = str(value)
