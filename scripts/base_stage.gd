extends Control
class_name BaseStage

@export_category("Objetos")
@export var enemy_container: HBoxContainer
@export var end_turn_button: Button
@export var player_hand: HBoxContainer

@export_category("Variaveis")
@export var deck_size: Label
@export var discard_pile_size: Label
@export var player: Control

var can_click: bool = false
var target_enemy = null
var previous_enemy = null


func _ready() -> void:
	connect_enemy_signal()
	get_tree().call_group("player_hand", "get_player_deck")


func _process(_delta: float) -> void:
	deck_size.text = str(player_hand.player_deck.size())
	discard_pile_size.text = str(player_hand.discard_pile.size())


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
	
	if enemy == previous_enemy:
		enemy.show_cursor()


# função executada quando o mouse sair da area do inimigo
func on_mouse_exited() -> void:
	can_click = false
	previous_enemy = target_enemy


func spawn_enemy(scene_path: String, passive_skill: String) -> void:
	var enemy_instance = load(scene_path)
	var enemy_scene = enemy_instance.instantiate()
	
	enemy_container.add_child(enemy_scene)
	var area = enemy_scene.get_node("CharacterBody2D/DetectionArea")
	area.mouse_entered.connect(on_mouse_area_entered.bind(enemy_scene))
	area.mouse_exited.connect(on_mouse_exited)
	enemy_scene.health = enemy_scene.max_health / 2
	enemy_scene.passive_skill = passive_skill
	enemy_scene.update_bar("health")
	enemy_scene.was_reborn = true


# pega a carta utilizada pelo player
func get_card_in_use(card: Control) -> void:
	if card.card_cost > player.actions or player.actions <= 0:
		return
	
	var card_used = card
	match card_used.card_type: # verifica o tipo da carta
		"attack":
			var damage: int = card.card_value
			if target_enemy != null:
				player.play_animation("attack")
				await get_tree().create_timer(0.5).timeout
				target_enemy.apply_card_effect(card_used, player.is_strengthened)
				player_hand_manager(card)
				return
			else:
				return
		
		"defense":
			player.apply_card_effect(card_used)
		
		"technique":
			if target_enemy != null:
				target_enemy.apply_card_effect(card_used)
			else:
				return
			
		"effect":
			if card_used.card_id == "enfraquecer":
				if target_enemy == null:
					return
				else:
					if target_enemy.action != "attack":
						return
					
					target_enemy.apply_card_effect(card_used)
					player_hand_manager(card)
					return
				
			player.apply_card_effect(card_used)
		
	player_hand_manager(card)


func player_hand_manager(card: Control) -> void:
	player.manage_action_points(card.card_cost, "decrease")
	if card.card_id == "corte_rapido":
		player.manage_action_points(card.card_cost, "increase")
	
	player_hand.discard_pile.append(card.card_id)
	card.queue_free()
	
	await get_tree().create_timer(0.5).timeout
	player_hand.draw_card(1) # compra uma nova carta


func _on_end_turn_pressed() -> void:
	end_turn_button.disabled = true
	
	for card in player_hand.get_children(): # descarta as cartas restantes da mao do player
		player_hand.discard_pile.append(card.card_id)
		card.queue_free()
		await get_tree().create_timer(0.5).timeout
	
	end_turn_button.text = "Turno do Inimigo"
	
	for enemy in get_tree().get_nodes_in_group("enemy"): # verifica cada inimigo
		enemy.apply_status_effect() # aplica status, caso tenha algum
		perform_enemy_action(enemy) # recebe a ação e passa pra funcao de executar a ação
		await get_tree().create_timer(1.5).timeout
	
	player.apply_status_effect()
	
	player_hand.draw_card(4) # compra novas cartas
	player.actions = 4 # restaura as ações do player
	player.update_bar("health") # atualizar a barra de vida
	player.update_bar("action") # atualiza a barra de acoes
	player.update_status() # atualiza o status
	
	get_new_enemy_action()
	
	await get_tree().create_timer(2.0).timeout
	end_turn_button.disabled = false
	end_turn_button.text = "End Turn"


func verify_battle_result() -> void:
	if enemy_container.get_child_count() == 0:
		print("resultado verificado")
		get_tree().change_scene_to_file("res://scenes/environments/winner.tscn")


func perform_enemy_action(enemy: Control) -> void:
	match enemy.action:
		"defense": # se for defesa ele ganha escudo
			enemy.play_animation("armor")
			await get_tree().create_timer(0.5).timeout
			enemy.shield += enemy.shield_value
			enemy.get_node("CharacterBody2D/ShieldContainer").visible = true
			enemy.get_node("CharacterBody2D/ShieldContainer/Label").text = str(enemy.shield)
			
		"attack": # se for ataque, causa dano ao player
			enemy.play_animation("attack")
			await get_tree().create_timer(enemy.attack_animation_time).timeout
			player.take_damage(enemy.damage, "physical")
		
		"poison":
			player.apply_status("poison")


func get_new_enemy_action() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.get_action()
