extends Node

var items = {
	"slime_ball":{
		"name": "Slime Ball",
		"description": "",
		"stackable": true,
		"icon": preload("res://assets/Slime_ball.png"),
		"sell_price": 5,
		"item_type": "item"
	},
	"bat_wing":{
		"name": "Bat Wing",
		"description": "",
		"stackable": true,
		"icon": preload("res://assets/bat_wing.png"),
		"sell_price": 15,
		"item_type": "item"
	},
	"wooden_sword":{
		"name": "Wooden Sword",
		"description": "",
		"stackable": false,
		"icon": preload("res://assets/wooden_sword.png"),
		"sell_price": 50,
		"bonus_damage": 5,
		"item_type": "weapon"
	}
}
