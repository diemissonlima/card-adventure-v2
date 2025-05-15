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
@export var passive_skill_info: Label

@export_category("Variaveis")
@export var enemy_name: String
@export var passive_skill: String
@export var max_health: int
@export var health: int
@export var damage: int
@export var shield: int
@export var attack_animation_time: float
@export var scene_path: String
# essas duas variaveis sao usadas somente no action ballon
@export var actions_list: Array[String]
@export var actions_probability: Dictionary
@export var actions_list_icons: Dictionary

var is_weakened: bool = false
var tenacity_active: bool = false
var was_reborn: bool = false
var is_burning_fury: bool = false
var is_final_fury: bool = false
var is_enrage: bool = false
var is_reflected: bool = false

var previous_damage: int = 0
var battle_thist_count: int = 0
var action: String = ""
var shield_value: int = 0


func _ready() -> void:
	init_bar()
	get_action()
	get_passive_skill()
	play_animation("idle")
	enemy_name_label.text = enemy_name


func init_bar() -> void:
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar_label.text = str(health) + " / " + str(max_health)


func update_bar(type: String) -> void:
	match type:
		"health":
			health_bar.value = health
			health_bar_label.text = str(health) + " / " + str(max_health)
		
		"shield":
			shield_container_label.text = str(shield)
			if shield <= 0:
				shield_container.visible = false


func get_passive_skill() -> void:
	var passive_skill_list: Array = [
		"burning fury", "rock hull", "protective shadows", "tenacity",
		"final fury", "vital roots", "retaliatory toxin", "battle thirst",
		"last breath", "rebirthing", "enrage"
	]
	
	var rng: int = randi() % passive_skill_list.size()
	passive_skill = passive_skill_list[rng]


func get_action() -> void:
	for key in actions_list:
		var rng: float = randf()
		if rng <= actions_probability[key]:
			action = key
			break
		
	action_ballon_icon.texture = load(actions_list_icons[action])
	
	if passive_skill == "vital roots":
		health += 3
		if health > max_health:
			health = max_health
		update_bar("health")
	
	match action:
		"attack":
			if passive_skill == "burning fury":
				if not is_burning_fury:
					damage += 2
					is_burning_fury = true
				
			if passive_skill == "final fury":
				if not is_final_fury:
					if health <= max_health / 2:
						damage = damage + 4
						is_final_fury = true
			
			if passive_skill == "enrage":
				if not is_enrage:
					if get_parent().get_child_count() == 1:
						damage += 10
						is_enrage = true
			
			if is_weakened:
				damage = previous_damage / 2
				
			action_ballon_label.text = str(damage)
			
		"defense":
			shield_value = randi_range(5, 10)
			action_ballon_label.text = str(shield_value)
			
		"poison":
			action_ballon_label.text = "1"
			
		"bleed":
			action_ballon_label.text = str(damage)
			
		"blind":
			action_ballon_label.text = "1"
		
		"reflect":
			action_ballon_label.text = "1"


func take_damage(value: int, times_used: int, damage_type: String) -> void:
	if passive_skill == "rock hull":
		value -= 1
	
	if passive_skill == "protective shadows" and damage_type == "physical":
		var dodge_chance: int = randi_range(0, 100)
		if dodge_chance <= 50:
			return
	
	var new_damage: int = value * times_used
	
	if is_reflected:
		get_tree().call_group("player", "take_damage", new_damage / 2, "physical")

	if shield > 0 and damage_type == "physical": # se tiver escudo e o ataque for fisico
		if new_damage <= shield: # dano menor ou igual ao escudo
			shield -= new_damage
			update_bar("shield")
			return
			
		else: # dano maior que o escudo
			var leftover = new_damage - shield
			shield = 0
			health -= leftover
			update_bar("shield")
			update_bar("health")
			play_animation("hit")
			
			if passive_skill == "retaliatory toxin":
				get_tree().call_group("player", "apply_status", "poison")
			
			if health <= 0:
				health = 0
				kill()
			
			update_bar("health")
			return
	
	# dano aplicado normal, sem a influencia do escudo
	health -= new_damage
	play_animation("hit")
	
	if passive_skill == "retaliatory toxin":
		get_tree().call_group("player", "apply_status", "poison")
	
	if health <= 0:
		if passive_skill == "tenacity":
			if not tenacity_active:
				health = 1
				tenacity_active = true
				update_bar("health")
				return
			
		health = 0
		damage = 0
		kill()
		
	update_bar("health")


func apply_card_effect(card: Control, is_strengthened: bool = false) -> void:
	if card.card_type == "attack" and card.attack_type == "single":
		if is_strengthened:
			var new_damage: int = card.card_value + (card.card_value * 25 / 100)
			take_damage(new_damage, card.times_used, card.damage_type)
			return
		
		take_damage(card.card_value, card.times_used, card.damage_type)
	
	elif card.card_type == "attack" and card.attack_type == "multiple":
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.take_damage(card.card_value, card.times_used, card.damage_type)
			
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
							previous_damage = damage
							damage = damage / 2
							update_action_ballon()
						
					"paralyzed":
						status_instance = preload("res://scenes/status/paralyzed.tscn")
					
					"reflect":
						status_instance = preload("res://scenes/status/reflect.tscn")
						is_reflected = true
					
				var status_scene = status_instance.instantiate()
				
				if status_scene.status_name == "reflect":
					status_scene.is_next_turn = true
				
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
					previous_damage = damage
					damage -= damage / 2
					update_action_ballon()
				
			"paralyzed":
				status_instance = preload("res://scenes/status/paralyzed.tscn")
			
			"reflect":
				status_instance = preload("res://scenes/status/reflect.tscn")
				is_reflected = true
			
		var status_scene = status_instance.instantiate()
		
		if status_scene.status_name == "reflect":
			status_scene.is_next_turn = true
		
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
			if is_weakened:
				is_weakened = false
				damage = previous_damage
		
		"reflect":
			is_reflected = false


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
	passive_skill_info.text = DeckManagement.passives_description[passive_skill]
	enemy_name_label.visible = true
	status_container.visible = false
	passive_skill_info.visible = true


func _on_detection_area_mouse_exited() -> void:
	enemy_name_label.visible = false
	status_container.visible = true
	passive_skill_info.visible = false


func _on_animation_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"hit":
			play_animation("idle")
		
		"death":
			if passive_skill == "last breath":
				for enemy in get_tree().get_nodes_in_group("enemy"):
					enemy.take_damage(10, 1, "physical")
				
				get_tree().call_group("player", "take_damage", 10, "physical")
			
			if passive_skill == "rebirthing":
				if not was_reborn:
					get_tree().call_group("stage", "spawn_enemy", scene_path, passive_skill)
			
			queue_free()
		
		"attack":
			play_animation("idle")
			if passive_skill == "battle thirst":
				battle_thist_count += 1
				if battle_thist_count == 2:
					health += 5
					battle_thist_count = 0
					if health > max_health:
						health = max_health
					update_bar("health")
		
		"armor":
			play_animation("idle")
