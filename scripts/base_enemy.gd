extends CharacterBody2D
class_name BaseEnemy

@export_category("Objetos")
@export var health_bar: TextureProgressBar
@export var health_bar_label: Label
@export var animation: AnimationPlayer
@export var status_container: HBoxContainer
@export var action_ballon: TextureRect
@export var action_ballon_label: Label

@export_category("Variaveis")
@export var enemy_name: String
@export var max_health: int
@export var health: int
@export var damage: int
@export var range_damage: Array[int]
@export var shield: int
# essas duas variaveis sao usadas somente no action ballon
@export var actions_list: Array[String]
@export var actions_list_icons: Dictionary

var previous_damage: int = 0
var is_weakened: bool = false
var action: String = ""
var shield_value: int = 0


func _ready() -> void:
	get_action()
	animation.play("idle")


func get_action() -> void:
	action = actions_list[randi() % actions_list.size()]
	action_ballon.texture = load(actions_list_icons[action])
	action_ballon.size
	action_ballon.visible = true
	
	match action:
		"attack":
			damage = randi_range(range_damage[0], range_damage[1])
			if is_weakened:
				damage -= damage / 2
			action_ballon_label.text = str(damage)
			
		"defense":
			pass
			
		"poison":
			pass
			
