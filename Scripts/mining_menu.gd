extends Control

@onready var iron: Button = $Iron

signal mine_reward
var iron_count := 1

func _ready():
	iron.pivot_offset = iron.size / 2
	iron.button_down.connect(
		func():
			iron.scale = Vector2(0.9, 0.9))
	iron.button_up.connect(
		func():
			iron.scale = Vector2(1.0, 1.0))
	iron.pressed.connect(mining)

func mining():
	mine_reward.emit(iron_count)
	
	var new_label = Label.new()
	add_child(new_label)
	new_label.text = "+" + str(iron_count) + "iron"
	new_label.position = Vector2(738, 210) - new_label.size/2
	var tween := create_tween()
	tween.set_parallel(true)
	var label_end_position : Vector2 = Vector2(800, 149) - new_label.size/2
	tween.tween_property(new_label, "position", label_end_position, 1.0)
	tween.tween_property(new_label, "modulate:a", 0, 1.0)
	tween.finished.connect(new_label.queue_free)
