extends Control

@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar
@onready var healthtext: Label = %healthtext
@onready var level: Label = $Level
@onready var inventory_button: TextureButton = %Inventory_button
@onready var attribute_button: TextureButton = %Attribute_button
@onready var inventory_menu: ScrollContainer = %Inventory_menu
@onready var grid_container: GridContainer = $Inventory_menu/GridContainer
@onready var gold: Label = %Gold


var ui_slots := []
var inventory := []
var current_gold := 0

func _ready():
	setup_button()
	setup_inventory()
	update_gold()

func setup_button():
	inventory_button.pivot_offset = inventory_button.size/2
	attribute_button.pivot_offset = attribute_button.size/2
	
	inventory_button.button_down.connect(func():
		inventory_button.scale = Vector2(0.9,0.9))
	inventory_button.button_up.connect(func():
		inventory_button.scale = Vector2(1.0,1.0))
	inventory_button.pressed.connect(func():
		inventory_menu.visible = true)
		
	attribute_button.button_down.connect(func():
		attribute_button.scale = Vector2(0.9,0.9))
	attribute_button.button_up.connect(func():
		attribute_button.scale = Vector2(1.0,1.0))
	attribute_button.pressed.connect(func():
		inventory_menu.visible = false)
		
func update_health_ui(current_hp, max_hp):
	texture_progress_bar.max_value = max_hp
	texture_progress_bar.value = current_hp
	healthtext.text = str(current_hp) + "/" + str(max_hp)

func setup_inventory():
	inventory_menu.visible = false
	ui_slots = grid_container.get_children()
	inventory.resize(20)
	inventory.fill(null)

func update_level(amount):
	level.text = "Level" + " " + str(amount)
	
func add_item(item_key):
	for b in range(inventory.size()): #Check tất cả các slot không trống để thêm amount cho item đã có
		if inventory[b] != null:
			if inventory[b]["id"] == item_key and Itemdatabase.items[item_key]["stackable"] == true:
				inventory[b]["amount"] += 1
				update_ui_slot(b)
				return
				
	for a in range(inventory.size()): #Check slot trống để tạo item mới
		if inventory[a] == null:
			inventory[a] = {"id": item_key, "amount": 1}
			update_ui_slot(a)
			return
			
func update_ui_slot(index):
	if inventory[index] != null:
		var key_item = inventory[index]["id"]
		ui_slots[index].get_node("Icon").texture = Itemdatabase.items[key_item]["icon"]
		ui_slots[index].get_node("Count").text = "x" + str(inventory[index]["amount"])
	else:
		ui_slots[index].get_node("Icon").texture = null
		ui_slots[index].get_node("Count").text = ""

func remove_item(item_key, amount):
	for c in range(inventory.size()):
		if amount <= 0:
			return
		if inventory[c] != null:
			if inventory[c]["id"] == item_key:
				if inventory[c]["amount"] > amount:
					inventory[c]["amount"] -= amount
					amount = 0
					update_ui_slot(c)
					return
				else:
					amount -= inventory[c]["amount"]
					inventory[c] = null
					update_ui_slot(c)

func add_gold(amount):
	current_gold += amount
	update_gold()

func spend_gold(amount):
	current_gold -= amount
	update_gold()
	
func update_gold():
	gold.text = "Gold:" + " " + str(current_gold)
