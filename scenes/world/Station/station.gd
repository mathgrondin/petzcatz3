class_name Station extends Node3D

@export var CHARGING_SPEED = 1;


func _ready():
	GameController.station = self

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("Entered Station")
	EventController.emit_signal("on_station_interact", true)


func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("exited Station")
	EventController.emit_signal("on_station_interact", false)
