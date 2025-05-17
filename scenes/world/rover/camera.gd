extends Camera3D
@export var follow_target: Node3D
@export var look_target: Node3D
@export var offset: Vector3
@export var rotation_speed: float = 2.0  # Vitesse de rotation ajustable

var angle: float = 0.0  # Angle de rotation autour du follow_target

func _process(delta):
	if follow_target and look_target:
		# Contrôle de l'angle avec les touches gauche et droite
		if Input.is_action_pressed("ui_left"):
			angle -= rotation_speed * delta
		if Input.is_action_pressed("ui_right"):
			angle += rotation_speed * delta
		
		# Calcul de la nouvelle position avec une rotation autour du follow_target
		var target_global_position = follow_target.global_position
		var rotated_offset = offset.rotated(Vector3.UP, angle)
		global_position = target_global_position + rotated_offset
		
		# Oriente la caméra vers le look_target
		look_at(look_target.global_position, Vector3.UP)
