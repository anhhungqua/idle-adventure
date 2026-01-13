extends Control

@onready var rest: TextureButton = %Resting
@onready var quest: TextureButton = %Quest
@export var player: Node2D
@export var character_menu: Control
@onready var quest_bg: TextureRect = %quest_bg
@onready var quest_name: Label = %Quest_name
@onready var quest_des: RichTextLabel = %Quest_des
@onready var quest_progress: Label = %Quest_progress
@onready var close: TextureButton = %Close
@onready var accept: TextureButton = %Accept
@onready var submit: TextureButton = %Submit
@onready var reward: RichTextLabel = %REWARD


var quests = {
	"quest_01":{
		"name": "Slime Hunt",
		"description": "The village is overrun by slimes! 
Defeat them to restore peace.",
		"item_key": "slime_ball",
		"quantity": 5,
		"reward": 50
	},
	"quest_02":{
		"name": "Bat Hunt",
		"description": "The village is overrun by bats! 
Defeat them to restore peace.",
		"item_key": "bat_wing",
		"quantity": 5,
		"reward": 100
	}
}
var quest_taken = false
var quest_index := 0
var current_quest = quests[quests.keys()[quest_index]]
signal quest_completed(item_key, amount)

var not_enough_money_tween: Tween

func _ready():
	setup_menu()
	setup_buttons()
	
func setup_menu():
	quest_bg.visible = false

func setup_buttons():
	rest.pivot_offset = rest.size/2
	rest.button_down.connect(func():
		rest.scale = Vector2(0.9,0.9))
	rest.button_up.connect(func():
		rest.scale = Vector2(1.0,1.0))
	rest.pressed.connect(func():
		resting(30))
	
	quest.pivot_offset = quest.size/2
	quest.button_down.connect(func():
		quest.scale = Vector2(0.9,0.9))
	quest.button_up.connect(func():
		quest.scale = Vector2(1.0,1.0))
	quest.pressed.connect(func():
		on_quest_pressed())
	
	close.pivot_offset = close.size/2
	close.button_down.connect(func():
		close.scale = Vector2(0.9,0.9))
	close.button_up.connect(func():
		close.scale = Vector2(1.0,1.0))
	close.pressed.connect(func():
		quest_bg.visible = false)
		
	accept.pivot_offset = accept.size/2
	accept.button_down.connect(func():
		accept.scale = Vector2(0.9,0.9))
	accept.button_up.connect(func():
		accept.scale = Vector2(1.0,1.0))
	accept.pressed.connect(func():
		on_accept_pressed())
		
	submit.pivot_offset = submit.size/2
	submit.button_down.connect(func():
		submit.scale = Vector2(0.9,0.9))
	submit.button_up.connect(func():
		submit.scale = Vector2(1.0,1.0))
	submit.pressed.connect(func():
		on_submit_pressed())

func on_quest_pressed():
	quest_name.text = current_quest["name"]
	quest_des.text = current_quest["description"]
	quest_progress.text = "PROGRESS:" + " " + str(quest_item_progress()) + "/" + str(current_quest["quantity"])
	reward.text = "REWARD:" + " " + str(current_quest["reward"]) + " " + "GOLD"
	quest_bg.visible = true
	if quest_taken == false:
		accept.visible = true
		submit.visible = false

func on_accept_pressed():
	quest_taken = true
	accept.visible = false
	submit.visible = true

func quest_item_progress():
	var item_count := 0
	for slot in range(character_menu.inventory.size()):
		if character_menu.inventory[slot] != null and character_menu.inventory[slot]["id"] == current_quest["item_key"]:
			item_count += character_menu.inventory[slot]["amount"]
	return item_count

func on_submit_pressed():
	var item_count = quest_item_progress()
	if item_count >= current_quest["quantity"]:
		quest_completed.emit(current_quest["item_key"], current_quest["quantity"])
		character_menu.add_gold(current_quest["reward"])
		quest_bg.visible = false
		quest_taken = false
		quest_index += 1
		if quest_index >= quests.size():
			quest.disabled = true
		else:
			current_quest = quests[quests.keys()[quest_index]]

func resting(cost):
	if character_menu.current_gold >= cost:
		character_menu.spend_gold(cost)
		player.set_health(player.max_health)
	else:
		var not_enough_money = Label.new()
		add_child(not_enough_money)
		not_enough_money.position = Vector2(20,593)
		not_enough_money.text = "Not Enough Gold"
		not_enough_money_tween = create_tween()
		not_enough_money_tween.set_parallel()
		not_enough_money_tween.tween_property(not_enough_money, "position:y", 553, 2)
		not_enough_money_tween.tween_property(not_enough_money, "modulate:a", 0, 2)
		not_enough_money_tween.finished.connect(not_enough_money.queue_free)
