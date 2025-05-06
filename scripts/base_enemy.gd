extends Control
class_name BaseEnemy

@export_category("Objetos")
@export var health_bar: TextureProgressBar
@export var health_bar_label: Label
@export var animation: AnimationPlayer
@export var status_container: HBoxContainer
@export var action_ballon: TextureRect
@export var action_ballon_icon: TextureRect
@export var action_ballon_label: Label
@export var shield_container: TextureRect
@export var shield_container_label: Label
@export var enemy_name_label: Label

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
	init_bar()
	get_action()
	play_animation("idle")
	enemy_name_label.text = enemy_name


func init_bar() -> void:
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar_label.text = str(health) + " / " + str(max_health)


func update_bar() -> void:
	health_bar.value = health
	health_bar_label.text = str(health) + " / " + str(max_health)
	
	shield_container_label.text = str(shield)
	if shield <= 0:
		shield_container.visible = false


func get_action() -> void:
	action = actions_list[randi() % actions_list.size()]
	action_ballon_icon.texture = load(actions_list_icons[action])
	
	match action:
		"attack":
			damage = randi_range(range_damage[0], range_damage[1])
			
			if is_weakened:
				damage -= damage / 2
				
			action_ballon_label.text = str(damage)
			
		"defense":
			shield = randi_range(5, 10)
			action_ballon_label.text = str(shield)
			
		"poison":
			action_ballon_label.text = "1"


func take_damage(value: int, times_used: int, damage_type: String) -> void:
	var new_damage: int = value * times_used
	
	if shield > 0 and damage_type == "physical": # se tiver escudo e o ataque for fisico
		if new_damage <= shield: # dano menor ou igual ao escudo
			shield -= new_damage
			update_bar()
			return
			
		else: # dano maior que o escudo
			var leftover = new_damage - shield
			shield = 0
			health -= leftover
			update_bar()
			play_animation("hit")
			
			if health <= 0:
				health = 0
				kill()
			
			update_bar()
			return
	
	# dano aplicado normal, sem a influencia do escudo
	health -= new_damage
	play_animation("hit")
	
	if health <= 0:
		health = 0
		damage = 0
		kill()
	
	update_bar()


func kill() -> void:
	play_animation("death")


func play_animation(anim_name: String) -> void:
	animation.play(anim_name)


# falta o apply card_effect, apply_status, apply_status_effect, calculate_status_damage
# update_status, clear_negative_effects
