extends Control
class_name BaseStage

@export_category("Objetos")
@export var end_turn_button: Button

@export_category("Variaveis")
@export var deck_size: Label
@export var discard_pile_size: Label
@export var player: Control

var can_click: bool = false
var target_enemy = null
var previous_enemy = null


func _ready() -> void:
	connect_enemy_signal()


	# conecta o sinal de mouse entered e mouse exited ao inimigo
func connect_enemy_signal() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var area: Area2D = enemy.get_node("CharacterBody2D/DetectionArea")
		area.mouse_entered.connect(on_mouse_area_entered.bind(enemy))
		area.mouse_exited.connect(on_mouse_exited)


# função executada quando o mouse entrar na area do inimigo
func on_mouse_area_entered(enemy) -> void:
	can_click = true
	target_enemy = enemy
	enemy.show_cursor()
	
	if previous_enemy != null:
		previous_enemy.hide_cursor()


# função executada quando o mouse sair da area do inimigo
func on_mouse_exited() -> void:
	can_click = false
	previous_enemy = target_enemy


# pega a carta utilizada pelo player
func get_card_in_use(card: Control) -> void:
	if card.card_cost > player.actions or player.actions <= 0:
		return
	
	var card_used = card
	match card_used.card_type: # verifica o tipo da carta
		"attack":
			if target_enemy != null:
				target_enemy.apply_card_effect(card_used, 0)
			else:
				return
		
		"defense":
			player.apply_card_effect(card_used)
		
		"technique":
			if target_enemy != null:
				target_enemy.apply_card_effect(card_used, 0)
			else:
				return
			
		"effect":
			if card_used.card_id == "enfraquecer":
				if target_enemy == null:
					return
				else:
					target_enemy.apply_card_effect(card_used, 0)
					return
				
			player.apply_card_effect(card_used)
	
	player.manage_action_points(card.card_cost, "decrease")
	if card.card_id == "corte_rapido":
		player.manage_action_points(card.card_cost, "increase")


# executa a ação da carta
func perform_action_card(card, target) -> void:
	pass
	#player.spend_energy()
	#if card.card_id == "corte_rapido":
		#player.gain_energy(1)
	#
	#$Background/Player/PlayerHand.discard_pile.append(card.card_id) # descarta a carta
	#card.queue_free() # deleta a carta da cena
	#
	#await get_tree().create_timer(0.5).timeout
	#$Background/Player/PlayerHand.draw_card(1) # compra uma nova carta
