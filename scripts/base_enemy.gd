extends Control
class_name BaseEnemy

@export_category("Objetos")
@export var health_bar: TextureProgressBar
@export var health_bar_label: Label
@export var health_bar_cursor: TextureRect
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


func apply_card_effect(card: Control, player_damage: int) -> void:
	var damage_caused: int = player_damage + card.card_value
	
	if card.card_type == "attack" and card.attack_type == "single":
		take_damage(damage_caused, card.times_used, card.damage_type)
	
	elif card.card_type == "attack" and card.attack_type == "multiple":
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.take_damage(damage_caused, card.times_used, card.damage_type)
			
	elif card.card_type == "technique": # carta de tecnica
		if card.attack_type == "multiple":
			for enemy in get_tree().get_nodes_in_group("enemy"):
				enemy.apply_status(card.status_type)
			return
			
		apply_status(card.status_type)
	
	elif card.card_type == "effect":
		if card.status_type == "weaken":
			apply_status(card.status_type)


# mostra o status no modifiers_container
func apply_status(type: String) -> void:
	var status_quantity: int = status_container.get_child_count()
	
	if status_quantity > 0:
		for status in status_container.get_children():
			if status.status_name == type:
				status.update_durability("increase")
			else:
				var status_instance
				match type:
					"poison":
						status_instance = preload("res://scenes/status/poison.tscn")
					
					"weaken":
						status_instance = preload("res://scenes/status/weaken.tscn")
						if not is_weakened:
							is_weakened = true
							damage -= damage / 2
							update_action_ballon()
						
					"paralyzed":
						pass
					
				var status_scene = status_instance.instantiate()
				status_container.add_child(status_scene)
				
	else:
		var status_instance
		match type:
			"poison":
				status_instance = preload("res://scenes/status/poison.tscn")
			
			"weaken":
				status_instance = preload("res://scenes/status/weaken.tscn")
				if not is_weakened:
					is_weakened = true
					damage -= damage / 2
					update_action_ballon()
				
			"paralyzed":
				pass
			
		var status_scene = status_instance.instantiate()
		status_container.add_child(status_scene)


# aplicado o efeito do status
func apply_status_effect() -> void:
	if status_container.get_child_count() > 0:
		for status in status_container.get_children():
			match status.status_name:
				"poison":
					take_damage(calculate_status_damage("poison", status.status_modifier), 1, "status")
					
	update_status()


func clear_negative_effects(effect: String) -> void:
	match effect:
		"weaken":
			is_weakened = false


func calculate_status_damage(type: String, modifier: int) -> int:
	var status_damage
	
	if type == "poison":
		status_damage = round(max_health * modifier / 100)
	
	return status_damage


# atualiza o status 
func update_status() -> void:
	if status_container.get_child_count() <= 0:
		return
	
	for status in status_container.get_children():
		status.update_durability("decrease")


func update_action_ballon() -> void:
	action_ballon_label.text = str(damage)


func kill() -> void:
	play_animation("death")


func show_cursor() -> void:
	health_bar_cursor.visible = true


func hide_cursor() -> void:
	health_bar_cursor.visible = false


func play_animation(anim_name: String) -> void:
	animation.play(anim_name)


func _on_detection_area_mouse_entered() -> void:
	enemy_name_label.visible = true
	status_container.visible = false


func _on_detection_area_mouse_exited() -> void:
	enemy_name_label.visible = false
	status_container.visible = true
