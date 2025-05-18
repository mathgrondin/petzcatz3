extends Node3D

@onready var ground_terrain := $Ground
@onready var mountains_terrain := $Mountains
@onready var walkable_markers: Node3D = $WalkableMarkers
const SPAWN_MARKER = preload("res://scenes/map/spawn_marker.tscn")
var walkable_data: Array = []
var spawn_world_position: Vector3
@onready var collectables_spawn_distances = {
	"red": {
		"min": 1,
		"max": 2
	},
	"blue": {
		"min": 3,
		"max": 7
	}
}
@export var origin_offset := Vector2.ZERO
@export var distance_scores : Dictionary
signal spawn_calculated(spawn_position: Vector3)

func _ready():
	await get_tree().process_frame
	randomize()
	ground_terrain.noise.seed = randi()
	mountains_terrain.noise.seed = randi()
	mountains_terrain.update_collision_shape()
	ground_terrain.update_collision_shape()
	calculate_walkability_map() # walkable_data se remplit ici
	var walkable_grid = build_walkable_grid(walkable_data, ground_terrain.resolution, ground_terrain.size)
	
	spawn_world_position = find_spawn_near_center_world(walkable_data)
	
	emit_signal("spawn_calculated", spawn_world_position)
	
	var grid_spawn := world_to_grid(spawn_world_position, ground_terrain.resolution, ground_terrain.size)
	distance_scores = compute_distance_scores(walkable_grid, grid_spawn)
	
func calculate_walkability_map():
	walkable_data.clear()
	var ground_mesh : Mesh = ground_terrain.mesh
	if not ground_mesh:
		return
	var arrays := ground_mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var min_x := INF
	var min_y := INF
	for vertex in vertices:
		min_x = min(min_x, vertex.x)
		min_y = min(min_y, vertex.z)
		var world_x := vertex.x
		var world_y := vertex.z
		var ground_height := vertex.y
		var mountain_height : float = mountains_terrain.get_height(world_x, world_y)
		var is_walkable := mountain_height <= ground_height + 0.1
		walkable_data.append({
			"x": world_x,
			"y": world_y,
			"height": ground_height,
			"walkable": is_walkable
		})
		#markers
		if is_walkable:
			var marker := SPAWN_MARKER.instantiate()
			marker.position = Vector3(world_x, ground_height, world_y)
			walkable_markers.add_child(marker)
	origin_offset = Vector2(min_x, min_y)

func build_walkable_grid(walkable_data: Array, resolution: int, size: float) -> Array:
	var width = resolution + 1
	var height = resolution + 1
	var grid = []
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(false)
		grid.append(row)
	for entry in walkable_data:
		var x = entry["x"]
		var y = entry["y"]
		var walkable = entry["walkable"]
		var grid_pos = world_to_grid_from_walkable(x, y, resolution, size)
		if grid_pos.x >= 0 and grid_pos.x < width and grid_pos.y >= 0 and grid_pos.y < height:
			grid[grid_pos.y][grid_pos.x] = walkable
	return grid

func find_spawn_near_center_world(walkable_data: Array) -> Vector3:
	var best_spawn := Vector3.ZERO
	var min_distance := INF

	for entry in walkable_data:
		if entry["walkable"]:
			var x = entry["x"]
			var y = entry["y"]
			var pos = Vector3(x, 0, y)
			var dist = pos.length()
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
			if next.x >= 0 and next.x < grid[0].size() and next.y >= 0 and next.y < grid.size():
				if grid[next.y][next.x] and not distance_map.has(next):
					distance_map[next] = current_distance + 1
					queue.append(next)
	return distance_map

func is_reachable(grid: Array, start: Vector2i, end: Vector2i) -> bool:
	var width = grid[0].size()
	var height = grid.size()
	var visited = {}
	var queue = [start]
	visited[start] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		if current == end:
			return true
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next = current + dir
			if next.x >= 0 and next.x < width and next.y >= 0 and next.y < height:
				if grid[next.y][next.x] and not visited.has(next):
					visited[next] = true
					queue.append(next)
	return false

func get_positions_by_distance_from_spawn(d_scores: Dictionary, target_d: int) -> Array:
	var positions := []
	for pos in d_scores.keys():
		if d_scores[pos] == target_d:
			positions.append(pos)
	return positions

func heuristic(a: Vector2i, b: Vector2i) -> float:
	# Use Manhattan distance or Euclidean distance
	return abs(a.x - b.x) + abs(a.y - b.y)

func neighbors(pos: Vector2i, grid: Array, allow_diagonal := true) -> Array:
	var results := []
	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1)
	]
	if allow_diagonal:
		directions += [
			Vector2i(1, 1), Vector2i(1, -1),
			Vector2i(-1, 1), Vector2i(-1, -1)
		]
	for dir in directions:
		var n = pos + dir
		if n.x >= 0 and n.x < grid[0].size() and n.y >= 0 and n.y < grid.size():
			if grid[n.y][n.x]: 
				results.append(n)
	return results

func a_star(grid: Array, start: Vector2i, goal: Vector2i) -> Array:
	var open_set := [start]
	var came_from := {}
	var g_score := {}
	var f_score := {}

	g_score[start] = 0
	f_score[start] = heuristic(start, goal)

	while open_set.size() > 0:
		open_set.sort_custom(func(a, b):
			return int(f_score.get(a, INF) - f_score.get(b, INF))
		)
		var current = open_set[0]
		if current == goal:
			var path = []
			while current in came_from:
				path.append(current)
				current = came_from[current]
			path.append(start)
			path.reverse()
			return path

		open_set.erase(current)
		for neighbor in neighbors(current, grid):
			var tentative_g_score = g_score.get(current, INF) + 1
			if tentative_g_score < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = tentative_g_score + heuristic(neighbor, goal)
				if not neighbor in open_set:
					open_set.append(neighbor)
	return [] 

func path_distance(grid: Array, start: Vector2i, goal: Vector2i) -> int:
	var path = a_star(grid, start, goal)
	if path.size() == 0:
		return -1
	else:
		return path.size() - 1

func world_to_grid(world_pos: Vector3, resolution: int = ground_terrain.resolution, size: float = ground_terrain.size) -> Vector2i:
	var cell_size = size / resolution
	var x = int(round(world_pos.x / cell_size))
	var y = int(round(world_pos.z / cell_size))
	return Vector2i(x, y)

func world_to_grid_from_walkable(x: float, y: float, resolution: int = ground_terrain.resolution, size: float = ground_terrain.size) -> Vector2i:
	var cell_size = size / resolution
	var gx = int(round(x / cell_size))
	var gy = int(round(y / cell_size))
	return Vector2i(gx, gy)


func grid_to_world(grid_pos: Vector2i, resolution: int = ground_terrain.resolution, size: float = ground_terrain.size) -> Vector3:
	var cell_size = size / resolution
	var world_x = grid_pos.x * cell_size
	var world_z = grid_pos.y * cell_size
	var height = ground_terrain.get_height(world_x, world_z)
	return Vector3(world_x, height, world_z)

func ordered_by_distance_positions(walkable_data : Array, spawn_world_pos : Vector3) -> Array:
	var w_positions := []
	for posi in walkable_data:
		if posi["walkable"]:
			w_positions.append(Vector3(posi["x"], posi["height"], posi["y"]))
	#print(w_positions)
	w_positions.sort_custom(func(a, b): return spawn_world_pos.distance_to(a) < spawn_world_pos.distance_to(b))
	#print(w_positions)

	#for w_p in w_positions:
		#print(spawn_world_pos.distance_to(w_p))
	return w_positions

func sorted_walkable_data(w_data : Array = walkable_data, spawn_pos : Vector3 = spawn_world_position) -> Array:
	var positions_by_distance_to_spawn := []
	# shortest distance at the end, parce que .pop_back() > .pop_front()
	for posi in walkable_data:
		if posi["walkable"]:
			var w_pos = Vector3(posi["x"], posi["height"], posi["y"])
			var w_pos_distance = spawn_pos.distance_to(w_pos)
			positions_by_distance_to_spawn.append({"position": w_pos, "distance": w_pos_distance})
	positions_by_distance_to_spawn.sort_custom(func(a, b): return a["distance"] > b["distance"])
	return positions_by_distance_to_spawn
