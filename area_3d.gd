extends Area3D

const ROT_SPEED = 2
@export var value: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))



func _on_body_entered(body: Node3D) -> void:
	if body is Node3D:
		GameController.collectable_collected(value)
		self.queue_free() # Replace with function body.
		print("collect 1")
