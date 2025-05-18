extends Node3D

@onready var station: Station = $Station
@onready var map_generation: Node3D = $MapGeneration
@onready var collectables: Node3D = $Collectables
const COLLECTABLE = preload("res://scenes/world/collectables/collectable.tscn")
const ROVER = preload("res://scenes/world/rover/rover.tscn")

func _ready() -> void:
	randomize()
	GameController.total_collectables = 0
	map_generation.connect("spawn_calculated", self.spawn_player)
	
	await get_tree().process_frame #important, timing issue
	decorate_world(GameController.missionIndex)

func generate_new_world():
	print("ray cast signal caught!")
	get_tree().reload_current_scene()

func spawn_player(spawn_position: Vector3) -> void:
	print("signal spawn_player caught")
	if find_child("Rover"):
		get_node("Rover").queue_free()
	var rover = ROVER.instantiate()
	station.global_position = spawn_position
	rover.global_position = spawn_position + Vector3(0, 4, 0)
	rover.connect("bad_spawn", self.generate_new_world)
	add_child(rover)

func decorate_world(missionIndex: int):
	var spawning_instructions = GameController.missions[missionIndex]["spawn"]
	var sorted_w_data : Array = map_generation.sorted_walkable_data()
	for c_type in spawning_instructions:
		for c_instance in range(spawning_instructions[c_type]):
			var safely_placed := false
			if not sorted_w_data.is_empty():
				while not safely_placed:
					var new_collectable = COLLECTABLE.instantiate()
					new_collectable.name = c_type
					var c_spawn_pos_object = sorted_w_data.pop_back()
					while c_spawn_pos_object["distance"] == 0:
						c_spawn_pos_object = sorted_w_data.pop_back()
					if c_spawn_pos_object == null:
						push_error("spawning_positions was emptied quicker than expected")
					#used_spawning_positions.append(c_spawn_pos_object)
					prints("spawning", new_collectable, c_type, "at", c_spawn_pos_object["position"])
					new_collectable.position = c_spawn_pos_object["position"]
					new_collectable.collectable_type = c_type
					collectables.add_child(new_collectable)
					await get_tree().process_frame
					if not new_collectable.ray_cast_3d.is_colliding():
						safely_placed = true
					else: new_collectable.queue_free()
