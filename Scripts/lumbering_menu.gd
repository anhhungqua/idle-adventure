extends Control

@onready var wood: Button = %Wood

signal lumber_reward
var wood_count := 1

func _ready():
	wood.pivot_offset = wood.size / 2
	wood.button_down.connect(func():
			wood.scale = Vector2(0.9, 0.9))
	wood.button_up.connect(func():
			wood.scale = Vector2(1.0, 1.0))
	wood.pressed.connect(lumbering)

func lumbering():
	lumber_reward.emit(wood_count)
	
	var new_label = Label.new()
	add_child(new_label)
	new_label.text = "+" + str(wood_count) + "wood"
	new_label.position = Vector2(738, 210) - new_label.size/2
	var tween := create_tween()
	tween.set_parallel(true)
	var label_end_position : Vector2 = Vector2(800, 149) - new_label.size/2
	tween.tween_property(new_label, "position", label_end_position, 1.0)
	tween.tween_property(new_label, "modulate:a", 0, 1.0)
	tween.finished.connect(new_label.queue_free)
