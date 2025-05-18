extends Node3D

@onready var station: Station = $Station
@onready var map_generation: Node3D = $MapGeneration
const ROVER = preload("res://scenes/world/rover/rover.tscn")

func _ready() -> void:
	GameController.total_collectables = 0
	map_generation.connect("spawn_calculated", self.spawn_player)

func spawn_player(spawn_position: Vector3) -> void:
	print("signal spawn_player caught")
	if find_child("Rover"):
		get_node("Rover").queue_free()
	var rover = ROVER.instantiate()
	station.global_position = spawn_position
	rover.global_position = spawn_position + Vector3(0, 4, 0)
	add_child(rover)
	

func set_spawn() -> void:
	print("map_generation.spawn_marker.position: ", map_generation.spawn_marker.position)
	
	station.position = map_generation.spawn_marker.position
