extends VehicleBody3D

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 300

func _physics_process(delta):
	var s = Input.get_axis("move_right", "move_left")
	steering = move_toward(steering,  s * MAX_STEER, delta * 10)
	engine_force = Input.get_axis("move_down", "move_up") * ENGINE_POWER
