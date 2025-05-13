extends TextureRect
class_name BaseStatus

@export_category("Variaveis")
@export var status_name: String
@export var status_modifier: int
@export var status_durability: int
@export var status_description: String

@export_category("Objetos")
@export var durability_label: Label


func _ready() -> void:
	durability_label.text = str(status_durability)


func update_durability(type: String) -> void:
	match type:
		"increase":
			status_durability += 1
			
		"decrease":
			status_durability -= 1
	
	if status_durability <= 0:
		if status_name == "strength":
			get_tree().call_group("player", "clear_bonus_damage")
		elif status_name == "weaken":
			get_tree().call_group("enemy", "clear_negative_effects", status_name)
		elif status_name == "blind":
			get_tree().call_group("player", "clear_negative_effects", status_name)
		
		await get_tree().create_timer(0.5).timeout
		queue_free()
		
		return
	
	durability_label.text = str(status_durability)
