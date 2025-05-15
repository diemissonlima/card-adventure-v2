extends TextureRect
class_name BaseStatus

@export_category("Variaveis")
@export var status_name: String
@export var status_modifier: int
@export var status_durability: int
@export var status_description: String

@export_category("Objetos")
@export var durability_label: Label
@export var description_label: Label

var is_next_turn: bool = false


func _ready() -> void:
	durability_label.text = str(status_durability)
	description_label.text = status_description


func update_durability(type: String, origin: String) -> void:
	match type:
		"increase":
			status_durability += 1
			
		"decrease":
				if not is_next_turn:
					status_durability -= 1
				
				if status_name in ["blind", "reflect"]:
					is_next_turn = false
	
	if status_durability <= 0:
		if status_name == "strength":
			get_tree().call_group("player", "clear_bonus_damage")
			
		elif status_name == "weaken":
			get_tree().call_group("enemy", "clear_negative_effects", status_name)
			
		elif status_name == "blind":
			get_tree().call_group("player", "clear_negative_effects", status_name)
			
		elif status_name == "reflect":
			get_tree().call_group(origin, "clear_negative_effects", status_name)
		
		await get_tree().create_timer(0.5).timeout
		queue_free()
		
		return
	
	durability_label.text = str(status_durability)


func _on_mouse_entered() -> void:
	description_label.visible = true


func _on_mouse_exited() -> void:
	description_label.visible = false
