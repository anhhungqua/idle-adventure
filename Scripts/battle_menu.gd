extends Control

@onready var explore_background: TextureRect = %explore_background
@onready var fight_button: TextureButton = %fight_button
@onready var battle_forest_bg: TextureRect = %battle_forest_bg
@onready var player: Node2D = %Player
@onready var enemy: Node2D = %Enemy
@onready var black_fade: ColorRect = %black_fade
@onready var winloseboard: TextureRect = %winloseboard
@onready var retreat: TextureButton = %Retreat
@onready var forward: TextureButton = %Forward
@onready var mine: TextureButton = %Mine
@onready var lumber: TextureButton = %Lumber
@onready var guild: TextureButton = %Guild


var victory_board := preload("res://assets/Victory_board.png")
var defeat_board := preload("res://assets/defeat_board.png")
var winlose_tween : Tween

var is_fighting = false
var player_turn = false
var enemy_turn = false
var victory = false

func _ready():
	hide_all()
	menu_setup()
	button_setup()

func hide_all():
	explore_background.visible = false
	battle_forest_bg.visible = false
	player.visible = false
	enemy.visible = false
	black_fade.visible = false
	winloseboard.visible = false
	retreat.visible = false
	forward.visible = false

func menu_setup():
	explore_background.visible = true
	if player.health <= 0:
		fight_button.disabled = true
	else:
		fight_button.disabled = false

func button_setup():
	fight_button.pivot_offset = fight_button.size/2
	fight_button.button_down.connect(func():
		fight_button.scale = Vector2(0.9, 0.9))
	fight_button.button_up.connect(func():
		fight_button.scale = Vector2(1.0, 1.0))
	fight_button.pressed.connect(func():
		prepare_combat()
		start_combat()
		disable_buttons())

	retreat.pivot_offset = retreat.size/2
	retreat.button_down.connect(func():
		retreat.scale = Vector2(0.9,0.9))
	retreat.button_up.connect(func():
		retreat.scale = Vector2(1.0,1.0))
	retreat.pressed.connect(func():
		hide_all()
		menu_setup()
		enable_buttons())

	forward.pivot_offset = forward.size/2
	forward.button_down.connect(func():
		forward.scale = Vector2(0.9,0.9))
	forward.button_up.connect(func():
		forward.scale = Vector2(1.0,1.0))
	forward.pressed.connect(func():
		prepare_combat()
		start_combat())

func disable_buttons():
	mine.disabled = true
	lumber.disabled = true
	guild.disabled = true

func enable_buttons():
	mine.disabled = false
	lumber.disabled = false
	guild.disabled = false
		
func battle_end():
	black_fade.visible = true
	winloseboard.visible = true
	retreat.visible = true
	forward.visible = true
	if victory:
		winloseboard.texture = victory_board
		forward.visible = true
		enemy.loot()
	else:
		winloseboard.texture = defeat_board
		forward.visible = false
	
	winloseboard.pivot_offset = winloseboard.size/2
	winloseboard.scale = Vector2(0,0)
	winlose_tween = create_tween()
	winlose_tween.set_trans(Tween.TRANS_QUART)
	winlose_tween.set_ease(Tween.EASE_OUT)
	winlose_tween.tween_property(winloseboard, "scale", Vector2(1.0,1.0), 1)

func prepare_combat():
	hide_all()
	victory = false
	battle_forest_bg.visible = true
	player.visible = true
	player.modulate.a = 1.0
	enemy.visible = true
	enemy.modulate.a = 1.0
	enemy.set_enemy()
	enemy.set_health()
	
func start_combat():
	if player.health > 0:
		is_fighting = true
		while is_fighting:
			#PLAYER TURN
			player_turn = true
			enemy.take_damage(player.damage)
			if enemy.health <= 0:
				is_fighting = false
				await enemy.play_death_effect()
				enemy.visible = false
				victory = true
				player.gain_xp(enemy.enemy_xp)
				await battle_end()
				break
			await get_tree().create_timer(1.0).timeout
			#ENEMY TURN
			player_turn = false
			enemy_turn = true
			player.take_damage(enemy.enemy_damage)
			if player.health <= 0:
				is_fighting = false
				await player.play_death_effect()
				player.visible = false
				await battle_end()
				break
			await get_tree().create_timer(1.0).timeout
	else:
		is_fighting = false
