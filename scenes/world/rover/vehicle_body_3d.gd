extends VehicleBody3D

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 300
var triggerRecover = false

func _physics_process(delta):
	var s = Input.get_axis("move_right", "move_left")
	steering = move_toward(steering,  s * MAX_STEER, delta * 10)
	engine_force = Input.get_axis("move_down", "move_up") * ENGINE_POWER
	
func _integrate_forces(state):
	#https://gamedevacademy.org/physicsdirectbodystate3d-in-godot-complete-guide/
	if triggerRecover == true:
		var new_transform = state.transform
		new_transform.origin.y = 5
		new_transform.basis = Basis(Vector3(1, 1, 1).normalized(), 0)
		state.transform = new_transform
		
		var velocity = state.linear_velocity
		velocity = Vector3(0, 0, 0)
		state.linear_velocity = velocity
		triggerRecover = false
	pass
	
func _input(event):
	if Input.is_action_just_pressed("reset"):
		triggerRecover = true
