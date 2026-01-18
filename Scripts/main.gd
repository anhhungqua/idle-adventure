extends Node2D

@onready var player: Node2D = %Player
@onready var mining_menu: Control = %"Mining Menu"
@onready var lumbering_menu: Control = %"Lumbering Menu"
@onready var mine: TextureButton = %Mine
@onready var lumber: TextureButton = %Lumber
@onready var resources: TextureButton = %Resources
@onready var resource_menu: Control = %"Resource Menu"
@onready var character_menu: Control = %CharacterMenu
@onready var character: TextureButton = %Character
@onready var explore: TextureButton = %Explore
@onready var battle_menu: Control = %"Battle Menu"
@onready var guild: TextureButton = %Guild
@onready var guild_menu: Control = %"Guild Menu"
@onready var back: TextureButton = %Back
@onready var buttons: Control = %Buttons


func _ready():
	hide_all()
	menu_setup()
	button_setup()
	connect_setup()

func hide_all():
	mining_menu.visible = false
	lumbering_menu.visible = false
	resource_menu.visible = false
	character_menu.visible = false
	battle_menu.visible = false
	guild_menu.visible = false
	back.visible = false

func menu_setup():
	hide_all()
	character_menu.visible = true
	character_menu.update_health_ui(player.health, player.max_health)
	character_menu.update_level(player.current_level)
	for i in range(3):
		character_menu.add_item("wooden_sword")
		character_menu.add_item("wooden_armor")
	
func button_setup():
	mine.pivot_offset = mine.size/2
	lumber.pivot_offset = lumber.size/2
	resources.pivot_offset = resources.size/2
	character.pivot_offset = character.size/2
	explore.pivot_offset = explore.size/2
	guild.pivot_offset = guild.size/2
	back.pivot_offset = back.size/2
	
	mine.pressed.connect(func():
		hide_all()
		mining_menu.visible = true)
	mine.button_down.connect(func():
		mine.scale = Vector2(0.9, 0.9))
	mine.button_up.connect(func():
		mine.scale = Vector2(1.0, 1.0))
		
	lumber.pressed.connect(func():
		hide_all()
		lumbering_menu.visible = true)
	lumber.button_down.connect(func():
		lumber.scale = Vector2(0.9, 0.9))
	lumber.button_up.connect(func():
		lumber.scale = Vector2(1.0, 1.0))
		
	resources.pressed.connect(func():
		hide_all()
		resource_menu.visible = true)
	resources.button_down.connect(func():
		resources.scale = Vector2(0.9, 0.9))
	resources.button_up.connect(func():
		resources.scale = Vector2(1.0, 1.0))
		
	character.pressed.connect(func():
		hide_all()
		character_menu.visible = true)
	character.button_down.connect(func():
		character.scale = Vector2(0.9, 0.9))
	character.button_up.connect(func():
		character.scale = Vector2(1.0, 1.0))
		
	explore.button_down.connect(func():
		explore.scale = Vector2(0.9,0.9))
	explore.button_up.connect(func():
		explore.scale = Vector2(1.0,1.0))
	explore.pressed.connect(func():
		hide_all()
		battle_menu.visible = true
		battle_menu.menu_setup())
	
	guild.button_down.connect(func():
		guild.scale = Vector2(0.9, 0.9))
	guild.button_up.connect(func():
		guild.scale = Vector2(1.0,1.0))
	guild.pressed.connect(func():
		hide_all()
		buttons.visible = false
		back.visible = true
		guild_menu.visible = true)
	
	back.button_down.connect(func():
		back.scale = Vector2(0.9,0.9))
	back.button_up.connect(func():
		back.scale = Vector2(1.0,1.0))
	back.pressed.connect(func():
		back.visible = false
		buttons.visible = true
		guild_menu.visible = false
		character_menu.visible = true)
	

func connect_setup():
	mining_menu.mine_reward.connect(func(iron):
		resource_menu.iron_count(iron))
	lumbering_menu.lumber_reward.connect(func(wood):
		resource_menu.wood_count(wood))
	player.update_player_value.connect(func(hp, max_hp, level):
		character_menu.update_health_ui(hp, max_hp)
		character_menu.update_level(level))
	guild_menu.quest_completed.connect(character_menu.remove_item)
	character_menu.bonus_damage.connect(player.bonus_damage)
	character_menu.bonus_armor.connect(player.bonus_armor)
