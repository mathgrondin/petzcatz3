extends Node3D

@onready var ground_terrain := $Ground
@onready var mountains_terrain := $Mountains
@onready var walkable_markers: Node3D = $WalkableMarkers
@onready var spawn_marker: Marker3D = $SpawnMarker
var walkable_data: Array = []

signal spawn_calculated(spawn_position: Vector3)

func _ready():
	await get_tree().process_frame
	mountains_terrain.update_collision_shape()
	ground_terrain.update_collision_shape()
	calculate_walkability_map()
	
	var walkable_grid = build_walkable_grid(walkable_data, ground_terrain.resolution)
	var spawn_world_pos = find_spawn_near_center_world(walkable_data)
	spawn_marker.position = spawn_world_pos
	emit_signal("spawn_calculated", spawn_world_pos)

func calculate_walkability_map():
	walkable_data.clear()
	var ground_mesh : Mesh = ground_terrain.mesh
	if not ground_mesh:
		push_warning("Ground mesh is missing!")
		return
	var arrays := ground_mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	for vertex in vertices:
		var world_x := vertex.x
		var world_y := vertex.z
		var ground_height := vertex.y
		var mountain_height : float = mountains_terrain.get_height(world_x, world_y)
		var is_walkable := mountain_height <= ground_height + 0.1
		#prints(ground_height, "/", mountain_height, "=", is_walkable)
		walkable_data.append({
			"x": world_x,
			"y": world_y,
			"walkable": is_walkable
		})
		#visual debug
		#if is_walkable:
			#var marker := MeshInstance3D.new()
			#marker.mesh = SphereMesh.new()
			#marker.scale = Vector3(0.666, 0.666, 0.666)
			#marker.position = Vector3(world_x, ground_height + 0.2, world_y)
			#walkable_markers.add_child(marker)

func build_walkable_grid(walkable_data: Array, resolution: int) -> Array:
	var grid := []
	var width = resolution + 1
	var height = resolution + 1

	for y in range(height):
		var row := []
		for x in range(width):
			var index = y * width + x
			if index >= walkable_data.size():
				push_error("Index out of bounds in walkable_data: %d" % index)
				row.append(false)
			else:
				row.append(walkable_data[index]["walkable"])
		grid.append(row)
	return grid

func find_spawn_near_center_world(walkable_data: Array) -> Vector3:
	var best_spawn := Vector3.ZERO
	var min_distance := INF

	for entry in walkable_data:
		if entry["walkable"]:
			var x = entry["x"]
			var y = entry["y"]
			var pos = Vector3(x, 0, y)
			var dist = pos.length()  # distance from center
			if dist < min_distance:
				min_distance = dist
				best_spawn = pos
	var spawn_y = ground_terrain.get_height(best_spawn.x, best_spawn.z)
	best_spawn.y = spawn_y
	return best_spawn

func compute_distance_scores(grid: Array, start: Vector2i) -> Dictionary:
	var distance_map := {}
	var queue := [start]
	distance_map[start] = 0
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_distance = distance_map[current]
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next = current + dir
			if not distance_map.has(next) \
					and next.x >= 0 and next.x < grid[0].size() \
					and next.y >= 0 and next.y < grid.size() \
					and grid[next.y][next.x]:
				distance_map[next] = current_distance + 1
				queue.append(next)
	return distance_map

func grid_to_world(grid_pos: Vector2i, size: float, resolution: int) -> Vector3:
	var step_size = size / resolution
	var world_x = grid_pos.x * step_size
	var world_z = grid_pos.y * step_size
	var world_y = ground_terrain.get_height(world_x, world_z)
	print("world_y: ", world_y)
	return Vector3(world_x, world_y, world_z)


func world_to_grid(world_pos: Vector3, size: float, resolution: int) -> Vector2i:
	var step_size = size / resolution
	var grid_x = int(round(world_pos.x / step_size))
	var grid_y = int(round(world_pos.z / step_size))
	return Vector2i(grid_x, grid_y)
