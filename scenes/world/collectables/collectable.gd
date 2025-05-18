extends Area3D

@onready var collectable_mesh_instance_3d: MeshInstance3D = $CollectableMeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
const ALGUE_DETAIL = preload("res://assets/UI/algue_detail.png")
const ALGUE_COLORS = {
	"red":
		Color(1.0, 0.23, 0.23),
	"blue":
		Color(0.0, 0.333, 1.0),
	"white":
		Color(1.0, 1.0, 1.0),
}
signal bad_collectable_spawn

#const ROT_SPEED = 2
@export var value: int = 1
@export_enum("red", "blue") var collectable_type: String:
	set(new_type):
		collectable_type = new_type

func _ready() -> void:
	await get_tree().process_frame
	if ray_cast_3d.is_colliding():
		emit_signal("bad_collectable_spawn")
	colorize(ALGUE_COLORS[collectable_type])

func colorize(color: Color) -> void:
	collectable_mesh_instance_3d.mesh.material.albedo_color = color

func _on_body_entered(body: Node3D) -> void:
	if body is Node3D and body.name == "VehicleBody3D":
		GameController.collectable_collected(value)
		self.queue_free() # Replace with function body.
		print("collect 1")
