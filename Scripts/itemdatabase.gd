extends Node

var items = {
	"slime_ball":{
		"name": "Slime Ball",
		"description": "",
		"stackable": true,
		"wearable": false,
		"icon": preload("res://assets/Slime_ball.png"),
		"sell_price": 5,
		"buy_price": 15,
		"item_type": "item"
	},
	"bat_wing":{
		"name": "Bat Wing",
		"description": "",
		"stackable": true,
		"wearable": false,
		"icon": preload("res://assets/bat_wing.png"),
		"sell_price": 15,
		"buy_price": 30,
		"item_type": "item"
	},
	"wooden_sword":{
		"name": "Wooden Sword",
		"description": "",
		"stackable": false,
		"wearable": true,
		"icon": preload("res://assets/wooden_sword.png"),
		"sell_price": 30,
		"buy_price": 100,
		"bonus_damage": 5,
		"item_type": "weapon"
	},
	"wooden_armor":{
		"name": "Wooden Armor",
		"description": "",
		"stackable": false,
		"wearable": true,
		"icon": preload("res://assets/wooden_armor.png"),
		"sell_price": 50,
		"buy_price": 120,
		"bonus_armor": 2,
		"item_type": "armor"
	}
}
