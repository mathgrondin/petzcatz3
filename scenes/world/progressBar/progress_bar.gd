class_name Juicy_bar extends Control

@export var top_layer_bar: ProgressBar
@export var bottom_layer_bar : ProgressBar

@export var min_value :float
@export var max_value: float
@export var current_value: float

func _ready() -> void:
	current_value = max_value
	set_progress_bar_default_values(top_layer_bar)
	set_progress_bar_default_values(bottom_layer_bar)
	pass # Replace with function body.
	
func set_progress_bar_default_values(bar:ProgressBar):
	bar.min_value = min_value
	bar.max_value = max_value
	bar.value = current_value
	pass
	
func change_current_value(value: float):
	current_value = clamp(value, min_value, max_value)
	run_juicy_tween(top_layer_bar, current_value, 0.2,0)
	run_juicy_tween(bottom_layer_bar, current_value, 0.4,0.1 )
	if(current_value <= min_value):
		get_tree().change_scene_to_file("res://scenes/world/endGame.tscn")
	pass
	
func run_juicy_tween(bar: ProgressBar, value: float, lenght: float, delay: float):
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value" , value, lenght).set_delay(delay)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
