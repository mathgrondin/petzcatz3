class_name Station extends Area3D

@export var CHARGING_SPEED = 0.25
	
func _ready():
	GameController.station = self

func _on_body_entered(body: Node3D) -> void:
	print("Entered Station")
	EventController.emit_signal("on_station_interact", true)

func _on_body_exited(body: Node3D) -> void:
	print("exited Station")
	EventController.emit_signal("on_station_interact", false)
