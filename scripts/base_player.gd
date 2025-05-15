extends Control
class_name BasePlayer

@export_category("Objetos")
@export var health_bar: TextureProgressBar
@export var action_bar: TextureProgressBar
@export var status_container: HBoxContainer
@export var shield_container: TextureRect
@export var animation: AnimationPlayer

@export_category("Variaveis")
@export var max_health: int
@export var health: int
@export var damage: int
@export var defense: int
@export var shield: int
@export var max_actions: int
@export var actions: int

@export_category("Variaveis Deck")
@export var deck_list: Array[String]

var bonus_damage: float = 0.0
var is_strengthened: bool = false
var is_blind: bool = false
var is_reflected: bool = false


func _ready() -> void:
	init_bar()
	play_animation("idle")


func init_bar() -> void:
	health_bar.max_value = max_health
	health_bar.value = health
	
	action_bar.max_value = max_actions
	action_bar.value = actions
	
	health_bar.get_node("Label").text = str(health) + " / " + str(max_health)
	action_bar.get_node("Label").text = str(actions)


func update_bar(type: String) -> void:
	match type:
		"health":
			health_bar.value = health
			health_bar.get_node("Label").text = str(health) + " / " + str(max_health)
		
		"action":
			action_bar.value = actions
			action_bar.get_node("Label").text = str(actions)
			
		"shield":
			shield_container.get_node("Label").text = str(shield)
			if shield <= 0:
				shield_container.visible = false


# função que recebe o dano
func take_damage(value: int, type: String, is_bleed = false) -> void:
	if shield > 0 and type == "physical":
		if value <= shield:
			shield -= value
			update_bar("shield")
			return
		else:
			var leftover = value - shield
			shield = 0
			health -= leftover
			update_bar("shield")
			update_bar("health")
			play_animation("hit")
			
			if is_bleed:
				apply_status("bleed")
				
			return
	
	health -= value
	update_bar("health")
	play_animation("hit")
	
	if is_bleed:
		apply_status("bleed")
	
	if health <= 0:
		kill()


func kill() -> void:
	play_animation("death")


# aplica o efeito da carta
func apply_card_effect(card: Control) -> void:
	if card.card_type == "defense":
		shield += card.card_value
		shield_container.visible = true
		shield_container.get_node("Label").text = str(shield)
	
	if card.card_type == "effect":
		if card.card_id == "pocao_vida":
			health += 20 # na verdade é pra calcular com base na vida maxima, corrigir depois
			if health > max_health:
				health = max_health
			update_bar("health")
		
		if card.card_id == "fortalecer":
			calculate_bonus_damage(card.card_value)
			apply_status(card.status_type)
			manage_action_points(card.card_cost, "increase")
			is_strengthened = true


# aplica o status
func apply_status(type: String) -> void:
	var status_instance
	if status_container.get_child_count() <= 5:
		match type:
			"poison":
				status_instance = preload("res://scenes/status/poison.tscn")
			
			"bleed":
				status_instance = preload("res://scenes/status/bleed.tscn")
			
			"strength":
				status_instance = preload("res://scenes/status/strength.tscn")
			
			"blind":
				status_instance = preload("res://scenes/status/blind.tscn")
				is_blind = true
			
			"reflect":
				status_instance = preload("res://scenes/status/reflect.tscn")
				is_reflected = true
		
		# verificar se status aplicado ja existe no player
		for status in status_container.get_children():
			if status.status_name == type:
				status.update_durability("increase")
				return
		
		var status_scene = status_instance.instantiate()
		
		if status_scene.status_name in ["blind", "reflect"]:
			status_scene.is_next_turn = true
		
		status_container.add_child(status_scene)


# aplica o efeito do status
func apply_status_effect() -> void:
	for status in status_container.get_children():
		if status.status_name == "poison":
			take_damage(calculate_status_damage("poison", status.status_modifier), "status")
		
		if status.status_name == "bleed":
			take_damage(calculate_status_damage("bleed", status.status_modifier), "status")
		
		await get_tree().create_timer(1.0).timeout


# calcula o dano conforme o tipo de status
func calculate_status_damage(status: String, modifier: int) -> int:
	var status_damage
	
	if status == "poison":
		status_damage = round(max_health * modifier / 100)
	
	if status == "bleed":
		status_damage = round(max_health * modifier / 100)
	
	return status_damage


# atualiza a durabilidade do status
func update_status() -> void:
	if status_container.get_child_count() <= 0:
		return
	
	for status in status_container.get_children():
		status.update_durability("decrease")


func calculate_bonus_damage(damage_modifier: float) -> void:
	if not is_strengthened:
		bonus_damage = damage * damage_modifier / 100
		damage += round(bonus_damage)


func clear_negative_effects(effect: String) -> void:
	match effect:
		"blind":
			if is_blind:
				is_blind = false


func clear_bonus_damage() -> void: # funcao chamada pelo base_status
	is_strengthened = false
	bonus_damage = 0.0


# gasta energia
func manage_action_points(quantity: int, type: String) -> void:
	match type:
		"increase":
			await get_tree().create_timer(0.5).timeout
			actions += quantity
			
		"decrease":
			actions -= quantity
	
	update_bar("action")


func play_animation(anim_name: String) -> void:
	animation.play(anim_name)


func _on_animation_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"hit":
			play_animation("idle")
		
		"attack":
			play_animation("idle")
