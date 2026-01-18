extends Control
@export var guild_menu : Control
@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar
@onready var healthtext: Label = %healthtext
@onready var level: Label = $Level
@onready var inventory_button: TextureButton = %Inventory_button
@onready var attribute_button: TextureButton = %Attribute_button
@onready var inventory_menu: ScrollContainer = %Inventory_menu
@onready var grid_container: GridContainer = $Inventory_menu/GridContainer
@onready var gold: Label = %Gold
var button_img = preload("res://assets/Button.png")
var equip_button : TextureButton = null
var unequip_button : TextureButton = null


var ui_slots := []
var inventory := []
var equipped_key := ["weapon", "armor", "accessory"]
var equipped := {
	"weapon": null,
	"armor": null,
	"accessory": null,
}
@onready var equipments: VBoxContainer = %Equipments
var equipment_slots := []
@onready var weapon_icon: TextureRect = %Weapon_icon
@onready var weapon_slot: TextureButton = %Weapon_slot
@onready var armor_slot: TextureButton = %Armor_slot
@onready var armor_icon: TextureRect = %Armor_icon

signal bonus_damage(amount)
signal bonus_armor(amount)

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
		
func update_health_ui(current_hp, max_hp): #lấy giá trị connect từ main từ player
	texture_progress_bar.max_value = max_hp
	texture_progress_bar.value = current_hp
	healthtext.text = str(current_hp) + "/" + str(max_hp)

func setup_inventory():
	inventory_menu.visible = false
	ui_slots = grid_container.get_children()
	inventory.resize(20)
	inventory.fill(null)
	for index in range(ui_slots.size()):
		ui_slots[index].pressed.connect(func():
			click_items(index))
	equipment_slots = equipments.get_children()
	for index in range(equipment_slots.size()):
		equipment_slots[index].pressed.connect(func():
			click_equipment(index))

func update_level(amount): #lấy giá trị connect từ main từ player
	level.text = "Level" + " " + str(amount)
	
func add_item(item_key):
	if Itemdatabase.items[item_key]["stackable"] == true: 
		for b in range(inventory.size()): 
			#Check tất cả các slot stackable để thêm amount cho item đã có
			#nếu stackable thỉ thực hiện rồi return
			#còn không stackable thì chạy tới dưới
			if inventory[b] != null:
				if inventory[b]["id"] == item_key:
					inventory[b]["amount"] += 1
					update_ui_slot(b)
					guild_menu.inventory_update_ui_slot()
					return

	for a in range(inventory.size()): #Check slot trống để tạo item mới
		if inventory[a] == null:
			inventory[a] = {"id": item_key, "amount": 1, "item_type": Itemdatabase.items[item_key]["item_type"], "wearable": Itemdatabase.items[item_key]["wearable"], "sell_price": Itemdatabase.items[item_key]["sell_price"], "stackable": Itemdatabase.items[item_key]["stackable"]}
			update_ui_slot(a)
			guild_menu.inventory_update_ui_slot()
			return #khi tìm đc slot thêm item vào rồi thì ngưng loop
			
func update_ui_slot(index):
	if inventory[index] != null: #check inventory slot đó có trống không, nếu không thì update ui
		var key_item = inventory[index]["id"]
		ui_slots[index].get_node("Icon").texture = Itemdatabase.items[key_item]["icon"]
		ui_slots[index].get_node("Count").text = "x" + str(inventory[index]["amount"])
	else: #nếu trống thì chuyển hình ảnh và text về không có
		ui_slots[index].get_node("Icon").texture = null
		ui_slots[index].get_node("Count").text = ""

func remove_item(item_key, amount):
	for c in range(inventory.size()): 
		#loop check amount được nhận từ main connect với signal quest completed 
		#từ guild_menu gửi về 2 tham số item_key và amount, lượt check đầu để check koi amount 
		#có được trừ hết ở dưới chưa, nếu amount chưa hết thì check tiếp slot kế tiếp.
		if amount <= 0:
			return
		if inventory[c] != null:
			if inventory[c]["id"] == item_key:
				if inventory[c]["amount"] > amount:
					inventory[c]["amount"] -= amount
					amount = 0
					update_ui_slot(c)
					guild_menu.inventory_update_ui_slot()
					return
					#nếu trừ hết thì return ngay khúc này.
				else:
					amount -= inventory[c]["amount"]
					inventory[c] = null
					update_ui_slot(c)
					guild_menu.inventory_update_ui_slot()
					#nếu chưa trừ hết thì lặp lại từ đầu check ở ô tiếp theo vì amount lúc này chưa bằng 0

func add_gold(amount):
	current_gold += amount
	update_gold()

func spend_gold(amount):
	current_gold -= amount
	update_gold()
	
func update_gold():
	gold.text = "Gold:" + " " + str(current_gold)

func click_items(index):
	if equip_button != null: 
		#check koi khi click nút mới 
		#nút trước đó đã tạo chưa, nếu tạo rồi thì delete
		#và trả về null để tạo nút mới khi click
		equip_button.queue_free()
		equip_button = null
		
	if inventory[index] == null: #check koi nút click index đó trong inventory index có data không
		return

	if inventory[index] != null: #check koi item trong data đó có phải weapon không
		if inventory[index]["wearable"] == true:
			equip_button = TextureButton.new()
			ui_slots[index].add_child(equip_button)
			equip_button.texture_normal = button_img
			equip_button.texture_hover = button_img
			equip_button.texture_pressed = button_img
			equip_button.ignore_texture_size = true
			equip_button.stretch_mode = TextureButton.STRETCH_SCALE
			equip_button.custom_minimum_size = Vector2(70,25)
			equip_button.pressed.connect(func():
				equip(index))
			
			var equip_text = Label.new()
			equip_button.add_child(equip_text)
			equip_text.text = "Equip"
			equip_text.size = Vector2(70, 25)
			equip_text.position = Vector2(0, 0)
			equip_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			equip_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func equip(index):
	#gán item id vào inventory_index_id
	#nếu slot equipped weapon là null thì slot đó nhận giá trị id itemtype bonus damage
	#nếu không trống thì lưu lại cái weapon id đang ở trong ô đó v ào old weapon id
	#đổi slot equipped weapon thành giá trị của weapon mới
	#add item cũ ngược vào inventory dùng add item id
	#xóa item mới trong inventory
	var inventory_index = inventory[index]
	var inventory_index_id = inventory_index["id"]
	if inventory[index]["wearable"] == true:
		if inventory[index]["item_type"] == "weapon":
			if equipped["weapon"] == null:
				equipped["weapon"] = {"id": inventory_index_id, "item_type": inventory_index["item_type"], "bonus_damage": Itemdatabase.items[inventory_index_id]["bonus_damage"]}
				weapon_icon.texture = Itemdatabase.items[inventory_index_id]["icon"]
				remove_item(inventory[index]["id"], 1)
				equip_button.queue_free()
				bonus_damage.emit(Itemdatabase.items[inventory_index_id]["bonus_damage"])
			else:
				var old_weapon_id = equipped["weapon"]["id"]
				var old_weapon_bonus = equipped["weapon"]["bonus_damage"]
				bonus_damage.emit(-old_weapon_bonus)
				equipped["weapon"] = {"id": inventory_index_id, "item_type": inventory_index["item_type"], "bonus_damage": Itemdatabase.items[inventory_index_id]["bonus_damage"]}
				weapon_icon.texture = Itemdatabase.items[inventory_index_id]["icon"]
				add_item(old_weapon_id)
				remove_item(inventory[index]["id"], 1)
				equip_button.queue_free()
				bonus_damage.emit(Itemdatabase.items[inventory_index_id]["bonus_damage"])
		elif inventory[index]["item_type"] == "armor":
			if equipped["armor"] == null:
				equipped["armor"] = {"id": inventory_index_id, "item_type": inventory_index["item_type"], "bonus_armor": Itemdatabase.items[inventory_index_id]["bonus_armor"]}
				armor_icon.texture = Itemdatabase.items[inventory_index_id]["icon"]
				remove_item(inventory[index]["id"], 1)
				equip_button.queue_free()
				bonus_armor.emit(Itemdatabase.items[inventory_index_id]["bonus_armor"])
			else:
				var old_armor_id = equipped["armor"]["id"]
				var old_armor_bonus = equipped["armor"]["bonus_armor"]
				bonus_armor.emit(-old_armor_bonus)
				equipped["armor"] = {"id": inventory_index_id, "item_type": inventory_index["item_type"], "bonus_armor": Itemdatabase.items[inventory_index_id]["bonus_armor"]}
				armor_icon.texture = Itemdatabase.items[inventory_index_id]["icon"]
				add_item(old_armor_id)
				remove_item(inventory[index]["id"], 1)
				equip_button.queue_free()
				bonus_armor.emit(Itemdatabase.items[inventory_index_id]["bonus_armor"])
				
func click_equipment(index):
	if unequip_button != null: 
		#check koi khi click nút mới 
		#nút trước đó đã tạo chưa, nếu tạo rồi thì delete
		#và trả về null để tạo nút mới khi click
		unequip_button.queue_free()
		unequip_button = null
	if equipped[equipped_key[index]] == null:
		return
	if equipped[equipped_key[index]] != null:
		unequip_button = TextureButton.new()
		equipment_slots[index].add_child(unequip_button)
		unequip_button.texture_normal = button_img
		unequip_button.texture_hover = button_img
		unequip_button.texture_pressed = button_img
		unequip_button.ignore_texture_size = true
		unequip_button.stretch_mode = TextureButton.STRETCH_SCALE
		unequip_button.custom_minimum_size = Vector2(100,25)
		unequip_button.position = Vector2(65,0)
		unequip_button.pressed.connect(func():
			unequip(index))

		var unequip_text = Label.new()
		unequip_button.add_child(unequip_text)
		unequip_text.text = "Unequip"
		unequip_text.size = Vector2(100, 25)
		unequip_text.position = Vector2(0, 0)
		unequip_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unequip_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func unequip(index):
		if equipped_key[index] == "weapon":
			if equipped["weapon"] == null:
				return
			if equipped["weapon"] != null:
				var old_weapon_bonus_damage = equipped["weapon"]["bonus_damage"]
				bonus_damage.emit(-old_weapon_bonus_damage)
				add_item(equipped["weapon"]["id"])
				equipped["weapon"] = null
				weapon_icon.texture = null
				unequip_button.queue_free()
		if equipped_key[index] == "armor":
			if equipped["armor"] == null:
				return
			if equipped["armor"] != null:
				var old_armor_bonus_armor = equipped["armor"]["bonus_armor"]
				bonus_armor.emit(-old_armor_bonus_armor)
				add_item(equipped["armor"]["id"])
				equipped["armor"] = null
				armor_icon.texture = null
				unequip_button.queue_free()
