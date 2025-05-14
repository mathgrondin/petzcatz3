extends Area3D

@export var progress_bar: Juicy_bar
@export var CHARGING_SPEED = 0.25
static var isCharging = false
	
func _process(delta: float) -> void:
	if (isCharging && progress_bar != null && progress_bar.current_value < progress_bar.max_value):
		print("charging")
		progress_bar.change_current_value(progress_bar.current_value + CHARGING_SPEED)
		
		

func _on_body_entered(body: Node3D) -> void:
	print("Entered Station")
	if(GameController.total_collectables >= GameController.target):
		get_tree().change_scene_to_file("res://scenes/world/win.tscn")
	isCharging = true


func _on_body_exited(body: Node3D) -> void:
	print("exited Station")
	isCharging = false
