extends Node2D

@onready var player_health: TextureProgressBar = %player_health
@onready var health_text: Label = %health_text


var health := 50
var max_health := 100
var current_xp := 0
var level_up_require := 30
var current_level := 1
var damage := 5

signal update_player_value(health, max_health, current_level)

func _ready():
	set_health(health)

func set_health(current_health):
	health = clamp(current_health, 0, max_health)
	player_health.max_value = max_health
	player_health.value = health
	health_text.text = str(health) + "/" + str(max_health)
	update_player_value.emit(health, max_health, current_level)

func take_damage(amount):
	set_health(health - amount)

func gain_xp(amount): #kết nối
	current_xp += amount
	level_up()
	
func level_up():
	if current_xp >= level_up_require:
		current_level += 1
		max_health = int(max_health * 1.1)
		current_xp = current_xp - level_up_require
		level_up_require = int(level_up_require * 1.1)
		set_health(max_health) #Hồi full máu

func play_death_effect():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1 )
	await tween.finished
