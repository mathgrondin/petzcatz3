#@tool
extends MeshInstance3D

var terrain_properties = {
	"Mountains": {
		"r": 64,
		"h": 512
	},
	"Ground": {
		"r": 16,
		"h": 8,
	}
}

@export var noise_scale := 0.42

@export var size := 1024.0

@export_enum("Mountains", "Ground") var terrain_type: String:
	set(new_type):
		terrain_type = new_type
		self.name = "Terrain"
		if terrain_type != null:
			resolution = terrain_properties[terrain_type]["r"]
			height = terrain_properties[terrain_type]["h"]
			self.name = terrain_type

@export_range(4, 256, 4) var resolution: float :
	set(new_resolution):
		resolution = new_resolution
		update_mesh()

@export_range(4.0, 2048.0, 4.0) var height :float :
	set(new_height):
		height = new_height
		material_override.set_shader_parameter("height", height * 2.0)
		update_mesh()

@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_mesh()
		if noise:
			noise.changed.connect(update_mesh)

func _ready() -> void:
	pass

func get_height(x: float, y: float) -> float:
	var n = noise.get_noise_2d(x * noise_scale, y * noise_scale)
	if terrain_type == "Ground":
		n = (n + 1.0) * 0.5  # remap from [-1, 1] to [0, 1]
	return n * height
	
func get_normal(x: float, y: float) -> Vector3:
	var epsilon := size / resolution
	var normal := Vector3(
		(get_height(x + epsilon, y) - get_height(x - epsilon, y)) / (2.0 * epsilon),
		1,
		(get_height(x, y + epsilon) - get_height(x, y - epsilon)) / (2.0 * epsilon),
	)
	return normal.normalized()

func update_mesh() -> void:
	var plane:= PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size, size)
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array: PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]
	
	for i:int in vertex_array.size():
		var vertex := vertex_array[i]
		var normal := Vector3.UP
		var tangent := Vector3.RIGHT
		if noise:
			vertex.y = get_height(vertex.x, vertex.z)
			normal = get_normal(vertex.x, vertex.z)
			tangent = normal.cross(Vector3.UP)
		vertex_array[i] = vertex
		normal_array[i] = normal
		tangent_array[4 * i] = tangent.x
		tangent_array[4 * i + 1] = tangent.y
		tangent_array[4 * i + 2] = tangent.z
	
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh = array_mesh
	update_collision_shape()

func update_collision_shape():
	if (get_child_count() > 0):
		for c in get_children():
			c.queue_free()
	create_trimesh_collision()
