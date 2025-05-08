extends HBoxContainer
class_name PlayerHand

@export var hand_size: int

var player_deck: Array = []
var aux_deck: Array = []
var discard_pile: Array = []


func get_player_deck() -> void:
	player_deck = DeckManagement.decks["paladin"].duplicate()
	aux_deck = player_deck.duplicate()
	
	player_deck.shuffle()
	
	for j in range(hand_size):
		var index: int = randi() % player_deck.size()
		var card = player_deck[index]
		add_card_to_hand(card)
		player_deck.remove_at(index)


func add_card_to_hand(card: String) -> void:
	var card_scene = load(CardFactory.card_list[card])
	var card_instance = card_scene.instantiate()
	add_child(card_instance)


func draw_card(quantity: int) -> void:
	if player_deck.size() == 0:
		for discarded_card in discard_pile:
			player_deck = discard_pile.duplicate()
			player_deck.shuffle()
			discard_pile.clear()
	
	if player_deck.size() > 0:
		for j in range(quantity):
			var card = player_deck[0]
			add_card_to_hand(card)
			player_deck.pop_front()
			await get_tree().create_timer(0.5).timeout
			
			if player_deck.size() == 0:
				player_deck = discard_pile.duplicate()
				player_deck.shuffle()
				discard_pile.clear()
