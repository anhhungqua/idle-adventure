extends Control

@onready var button: Button = %Button

func _ready():
	button.pivot_offset = button.size/2
	button.button_down.connect(func():
		button.scale = Vector2(0.9, 0.9))
	button.button_up.connect(func():
		button.scale = Vector2(1.0, 1.0))
	button.pressed.connect(func():
		get_tree().change_scene_to_file("res://Scenes/main.tscn"))
		
