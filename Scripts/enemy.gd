extends Node2D

@onready var enemy_texture: Sprite2D = %enemy_texture
@onready var enemy_health: TextureProgressBar = %enemy_health
@onready var enemy_health_text: Label = %enemy_health_text
@onready var enemy_name: Label = %enemy_name
@onready var character_menu: Control = %CharacterMenu

var enemy_list: Array[Dictionary] = [{
	"name": "Slime",
	"hp": 20,
	"damage": 2,
	"xp": 10,
	"texture": preload("res://assets/slime.png"),
	"loot": "slime_ball",
	"rate": 70.0
},{
	"name": "Evil Bat",
	"hp": 40,
	"damage": 2,
	"xp": 20,
	"texture": preload("res://assets/doi quy.png"),
	"loot": "bat_wing",
	"rate": 30.0
}]
var max_health := 0
var health := 0
var enemy_damage := 0
var enemy_index := 0
var enemy_xp := 0

func _ready():
	set_enemy()
	set_health()

func random_enemy():
	var total_rate = 0
	for key in range(enemy_list.size()):
		total_rate += enemy_list[key]["rate"]
	var random_value = randf_range(0, total_rate)
	var current_rate = 0
	for key in range(enemy_list.size()):
		current_rate += enemy_list[key]["rate"]
		#rate cộng dồn nếu rate bằng hoặc lớn hơn số random thì return key đó
		#còn nếu rate cộng dồn lớn hơn số random thì tiếp tục cộng rate của key tiếp theo cho đến
		#khi bằng hoặc lớn hơn số random, từ đó return cái key cuối cùng được cộng.
		if random_value <= current_rate:
			return key

func set_enemy():
	enemy_index = random_enemy() 
	#gán chỉ số index trong random enemy vào enemy index
	enemy_name.text = enemy_list[enemy_index]["name"]
	enemy_texture.texture = enemy_list[enemy_index]["texture"]
	enemy_damage = enemy_list[enemy_index]["damage"]
	max_health = enemy_list[enemy_index]["hp"]
	enemy_health.max_value = max_health
	health = max_health
	enemy_xp = enemy_list[enemy_index]["xp"]
	
func set_health():
	health = clamp(health, 0, max_health)
	enemy_health.value = health
	enemy_health_text.text = str(health) + "/" + str(max_health)
	
func take_damage(amount):
	health -= amount
	set_health()

func play_death_effect():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1 )
	await tween.finished

func loot():
	character_menu.add_item(enemy_list[enemy_index]["loot"])
	#Tự động chuyển dữ liệu item loot được sang inventory của player luôn.
