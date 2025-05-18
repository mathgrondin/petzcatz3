extends Area3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
const ALGUE_DETAIL = preload("res://assets/UI/algue_detail.png")

#const ROT_SPEED = 2
@export var value: int = 1
@export_enum("red", "blue") var collectable_type: String:
	set(new_type):
		collectable_type = new_type
		match collectable_type:
			"red":
				Color(1.0, 0.23, 0.23)
			"blue":
				Color(0.0, 0.333, 1.0)
			_:
				Color(1.0, 1.0, 1.0)


func colorize(color: Color) -> void:
	mesh_instance_3d.mesh.get_active_material(0).albedo_color = color


func _on_body_entered(body: Node3D) -> void:
	if body is Node3D:
		GameController.collectable_collected(value)
		self.queue_free() # Replace with function body.
		print("collect 1")
