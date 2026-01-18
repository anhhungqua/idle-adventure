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
@onready var shop: TextureButton = %Shop
@onready var shop_menu: Control = $Shop_menu
@onready var grid_container_inventory: GridContainer = %GridContainerInventory
@onready var grid_container_shop: GridContainer = %GridContainerShop
@onready var shop_button: TextureButton = %shop_button
@onready var buyback_button: TextureButton = %buyback_button
@onready var shop_inventory_node: ScrollContainer = %Shop_inventory_node
@onready var buyback_inventory_node: ScrollContainer = %buyback_inventory_node
@onready var grid_containerbuyback: GridContainer = %GridContainerbuyback


# ========== QUEST SYSTEM ==========
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
# ========== SHOP SYSTEM ==========
var not_enough_money_tween: Tween
var btn_texture = preload("res://assets/Button.png")
var inventory_ui_slots = []
var player_sell_btn : TextureButton
# ========== SHOP INVENTORY ==========
var shop_inventory = []
var shop_ui_slots = []
var shop_buy_btn : TextureButton
# ========== BUYBACK INVENTORY ==========
var buyback_inventory = []
var buyback_ui_slots = []
var buyback_buy_btn: TextureButton

# ========== SETUP ==========
func _ready():
	setup_menu()
	setup_buttons()
	
func hide_all():
	quest_bg.visible = false
	shop_menu.visible = false
	buyback_inventory_node.visible = false
	
func setup_menu():
	hide_all()
	setup_inventory()

func setup_inventory():
	inventory_ui_slots = grid_container_inventory.get_children()
	for i in range(inventory_ui_slots.size()):
		inventory_ui_slots[i].pressed.connect(func():
			click_invenntory(i))
	shop_ui_slots = grid_container_shop.get_children()
	for i in range(shop_ui_slots.size()):
		shop_ui_slots[i].pressed.connect(func():
			click_shop(i))
	shop_inventory.resize(20)
	shop_inventory.fill(null)
	shop_inventory[0] = "wooden_sword"
	buyback_inventory.resize(20)
	buyback_inventory.fill(null)
	buyback_ui_slots = grid_containerbuyback.get_children()
	for i in range(buyback_ui_slots.size()):
		buyback_ui_slots[i].pressed.connect(func():
			click_buyback(i))

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
		hide_all()
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
	
	shop.pivot_offset = shop.size/2
	shop.button_down.connect(func():
		shop.scale = Vector2(0.9,0.9))
	shop.button_up.connect(func():
		shop.scale = Vector2(1.0,1.0))
	shop.pressed.connect(func():
		hide_all()
		shop_menu.visible = true
		inventory_update_ui_slot()
		shop_update_ui_slot())
	
	shop_button.pivot_offset = shop_button.size/2
	shop_button.button_down.connect(func():
		shop_button.scale = Vector2(0.9,0.9))
	shop_button.button_up.connect(func():
		shop_button.scale = Vector2(1.0,1.0))
	shop_button.pressed.connect(func():
		shop_inventory_node.visible = true
		buyback_inventory_node.visible = false)
		
	buyback_button.pivot_offset = buyback_button.size/2
	buyback_button.button_down.connect(func():
		buyback_button.scale = Vector2(0.9,0.9))
	buyback_button.button_up.connect(func():
		buyback_button.scale = Vector2(1.0,1.0))
	buyback_button.pressed.connect(func():
		shop_inventory_node.visible = false
		buyback_inventory_node.visible = true)
		
# ========== QUEST FUNCTIONS ==========
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
	#tạo item_count từ 0, với mỗi slot trong inventory nếu không null và
	#item đó có cùng id với quest id thì gán amount của item đó bằng item count
	#lặp lại đến hết inventory sẽ ra được tồng số item quest yêu cầu mà inventory đang có.
	#return để lấy giá trị của item_count dùng lại cho các code khác
	var item_count := 0
	for slot in range(character_menu.inventory.size()):
		if character_menu.inventory[slot] != null and character_menu.inventory[slot]["id"] == current_quest["item_key"]:
			item_count += character_menu.inventory[slot]["amount"]
	return item_count

func on_submit_pressed():
	#dùng lại số ở trên để check số lượng item trong inventory bằng với số lượng item quest yêu cầu không
	#nếu số lượng item trong inventory lớn hơn hoặc bằng thì sẽ emit cái signal chứa 2 tham số là item key
	#và quantity rồi lấy main kết nối với remove_item bên inventory để trừ số lượng item quest yêu cầu
	#đồng thời add gold reward trong character menu luon
	#sau đó thay đổi index của quest để lượt sau khi bấm vào quest thì ra quest mới.
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
			
# ========== GUILD FUNCTIONS ==========
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

# ========== PLAYER INVENTORY (in shop) ==========
func inventory_update_ui_slot():
	for i in range(character_menu.inventory.size()):
		if character_menu.inventory[i] != null:
			var character_menu_id =  character_menu.inventory[i]["id"]
			inventory_ui_slots[i].get_node("Icon").texture = Itemdatabase.items[character_menu_id]["icon"]
			inventory_ui_slots[i].get_node("Count").text = str(character_menu.inventory[i]["amount"])
		else:
			inventory_ui_slots[i].get_node("Icon").texture = null
			inventory_ui_slots[i].get_node("Count").text = ""

func click_invenntory(i):
	if player_sell_btn != null:
		player_sell_btn.queue_free()
		player_sell_btn = null
	if character_menu.inventory[i] == null:
		return
	else:
		player_sell_btn = TextureButton.new()
		inventory_ui_slots[i].add_child(player_sell_btn)
		player_sell_btn.texture_normal = btn_texture
		player_sell_btn.texture_pressed = btn_texture
		player_sell_btn.texture_hover = btn_texture
		player_sell_btn.ignore_texture_size = true
		player_sell_btn.stretch_mode = TextureButton.STRETCH_SCALE
		player_sell_btn.custom_minimum_size = Vector2(70,25)
		player_sell_btn.pressed.connect(func():
			selling(i)
			player_sell_btn.queue_free())
		var sell_button_text = Label.new()
		player_sell_btn.add_child(sell_button_text)
		sell_button_text.text = "Sell"
		sell_button_text.size = Vector2(70, 25)
		sell_button_text.position = Vector2(0, 0)
		sell_button_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sell_button_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func selling(i):
	#check nếu item trong inventory bên character_menu có stackable hay không
	#nếu có thì check nếu buyback không trống thì cộng amount dựa trên id
	#update buybackui, add_gold/remove_item đã bao gồm update bên inventory bên character, update inventory bên đây
	#nếu không stackable thì check xin slot nào trống thì thêm item vào dựa trên id
	#cũng update ui buyback, addgold/remove_item, và update inventory bên đây
	if character_menu.inventory[i]["stackable"] == true:
		for a in range(buyback_inventory.size()):
			if buyback_inventory[a] != null:
				if buyback_inventory[a]["id"] == character_menu.inventory[i]["id"]:
					buyback_inventory[a]["amount"] += 1
					update_buyback_ui_slots(a)
					character_menu.add_gold(character_menu.inventory[i]["sell_price"])
					character_menu.remove_item(character_menu.inventory[i]["id"], 1)
					inventory_update_ui_slot()
					return
					
	if buyback_inventory[19] != null: 
		#FIFO, check nếu slot cuối có item không, nếu có thì thực hiện cộng dồn
		#sở dĩ để size-1 vì nếu khi cộng dồn 19+1=20, 20 không có dữ liệu sẽ crash
		#cho nên 18+1=19 là tới slot cuối cùng r.
		for c in range(buyback_inventory.size()-1):
			buyback_inventory[c] = buyback_inventory[c+1]
		buyback_inventory[19] = null
		for k in range(buyback_inventory.size()):
			update_buyback_ui_slots(k)
		
	for b in range(buyback_inventory.size()):
		if buyback_inventory[b] == null:
			buyback_inventory[b] = {"id": character_menu.inventory[i]["id"], "amount": 1}
			update_buyback_ui_slots(b)
			character_menu.add_gold(character_menu.inventory[i]["sell_price"])
			character_menu.remove_item(character_menu.inventory[i]["id"], 1)
			inventory_update_ui_slot()
			return

# ========== SHOP TAB ==========
func shop_update_ui_slot():
	for i in range(shop_inventory.size()):
		if shop_inventory[i] != null:
			shop_ui_slots[i].get_node("Icon").texture = Itemdatabase.items[shop_inventory[i]]["icon"]
		else:
			shop_ui_slots[i].get_node("Icon").texture = null

func click_shop(i):
	if shop_buy_btn != null:
		shop_buy_btn.queue_free()
		shop_buy_btn = null
	if shop_inventory[i] == null:
		return
	else:
		shop_buy_btn = TextureButton.new()
		shop_ui_slots[i].add_child(shop_buy_btn)
		shop_buy_btn.texture_normal = btn_texture
		shop_buy_btn.texture_pressed = btn_texture
		shop_buy_btn.texture_hover = btn_texture
		shop_buy_btn.ignore_texture_size = true
		shop_buy_btn.stretch_mode = TextureButton.STRETCH_SCALE
		shop_buy_btn.custom_minimum_size = Vector2(70,25)
		shop_buy_btn.pressed.connect(func():
			buying(i)
			shop_buy_btn.queue_free())
		var buy_button_text = Label.new()
		shop_buy_btn.add_child(buy_button_text)
		buy_button_text.text = "Buy"
		buy_button_text.size = Vector2(70, 25)
		buy_button_text.position = Vector2(0, 0)
		buy_button_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		buy_button_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func buying(i):
	if character_menu.current_gold >= Itemdatabase.items[shop_inventory[i]]["buy_price"]:
		character_menu.add_item(shop_inventory[i])
		character_menu.spend_gold(Itemdatabase.items[shop_inventory[i]]["buy_price"])
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

# ========== BUYBACK TAB ==========
func update_buyback_ui_slots(index):
	 #phải check null trước mới gán không thôi cái slot null thì gán vào sẽ crash.
		if buyback_inventory[index] != null:
			var buyback_inventory_id = buyback_inventory[index]["id"]
			buyback_ui_slots[index].get_node("Icon").texture = Itemdatabase.items[buyback_inventory_id]["icon"]
			buyback_ui_slots[index].get_node("Label").text = str(buyback_inventory[index]["amount"])
		else:
			buyback_ui_slots[index].get_node("Icon").texture = null
			buyback_ui_slots[index].get_node("Label").text = ""

func click_buyback(i):
	if buyback_buy_btn != null:
		buyback_buy_btn.queue_free()
		buyback_buy_btn = null
	if buyback_inventory[i] == null:
		return
	else:
		buyback_buy_btn = TextureButton.new()
		buyback_ui_slots[i].add_child(buyback_buy_btn)
		buyback_buy_btn.texture_normal = btn_texture
		buyback_buy_btn.texture_pressed = btn_texture
		buyback_buy_btn.texture_hover = btn_texture
		buyback_buy_btn.ignore_texture_size = true
		buyback_buy_btn.stretch_mode = TextureButton.STRETCH_SCALE
		buyback_buy_btn.custom_minimum_size = Vector2(70,25)
		buyback_buy_btn.pressed.connect(func():
			buyback(i)
			buyback_buy_btn.queue_free())
		var buyback_button_slot_text = Label.new()
		buyback_buy_btn.add_child(buyback_button_slot_text)
		buyback_button_slot_text.text = "Buy"
		buyback_button_slot_text.size = Vector2(70, 25)
		buyback_button_slot_text.position = Vector2(0, 0)
		buyback_button_slot_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		buyback_button_slot_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func buyback(i):
	var key_id = buyback_inventory[i]["id"]
	if character_menu.current_gold >= Itemdatabase.items[key_id]["buy_price"]:
		character_menu.add_item(key_id)
		character_menu.spend_gold(Itemdatabase.items[key_id]["buy_price"])
		buyback_inventory[i]["amount"] -= 1
		if buyback_inventory[i]["amount"] == 0:
			buyback_inventory[i] = null
		update_buyback_ui_slots(i)
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
