extends Control

@onready var tree_number: Label = %tree_number
@onready var iron_number: Label = %iron_number
var current_tree := 0
var current_iron := 0

func _ready():
	tree_number.text = "x" + str(current_tree)
	iron_number.text = "x" + str(current_iron)


func wood_count(amount):
	current_tree += amount
	tree_number.text = "x" + str(current_tree)

func iron_count(amount):
	current_iron += amount
	iron_number.text = "x" + str(current_iron)
