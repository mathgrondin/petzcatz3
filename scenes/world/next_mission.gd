extends Control

@onready var label: Label = $missionTarget

func _ready():
	var target = str(GameController.missions[GameController.missionIndex].collect.red).pad_decimals(0)
	label.text = target


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")
