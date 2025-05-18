extends Node

# Called when the node enters the scene tree for the first time.
var total_collectables: int = 0
var isCharging = false;
var progress_bar: Juicy_bar;
var station: Station;
var missions: Array;
var missionIndex: int = 0


func _ready():
	EventController.connect("on_station_interact", onStationInteract)
	var file = "res://resources/missions.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	missions = JSON.parse_string(json_as_text)
	
func _process(delta: float) -> void:
	if(isCharging):
		processMission()
		processCharging()

func processMission():
	if(GameController.total_collectables >= missions[missionIndex].collect.red):
		if(missionIndex == missions.size() -1):
			get_tree().change_scene_to_file("res://scenes/world/win.tscn")
		else:
			missionIndex = missionIndex + 1;
		var next_mission_scene = load("res://scenes/world/nextMission.tscn")
		var next_mission_instance = next_mission_scene.instantiate()
		get_tree().current_scene.add_child(next_mission_instance)

	
		
func processCharging():
	if(progress_bar != null && progress_bar.current_value < progress_bar.max_value):
		progress_bar.change_current_value(progress_bar.current_value + station.CHARGING_SPEED)
		var msg = "charging" + "%.02f" % progress_bar.current_value
		print(msg)


func collectable_collected(value: int):
	total_collectables += value
	EventController.emit_signal("collectable_collected", total_collectables)
	
func onStationInteract(newIsCharging: bool):
	isCharging = newIsCharging
	
