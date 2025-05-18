extends Control

@onready var label: Label = $missionTarget

func _ready():
	var target = str(GameController.missions[GameController.missionIndex].collect.red).pad_decimals(0)
	label.text = target


func _on_texture_button_pressed() -> void:
	var next_mission_scene = load("res://scenes/NextMission.tscn")
	var next_mission_instance = next_mission_scene.instantiate()
	get_tree().current_scene.add_child(next_mission_instance)
