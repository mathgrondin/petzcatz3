extends Camera3D
@export var follow_target: Node3D
@export var look_target: Node3D
@export var offset: Vector3

func _process(delta):
	var target_global_position = follow_target.global_position
	global_position = target_global_position + offset

  #look_at(look_target.grobal_position)
