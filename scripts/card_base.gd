extends Control
class_name CardBase

@export_category("Objetos")
@export var box_name_label: Label

@export_category("Variaveis")
@export var card_name: String # nome da carta
@export var card_id: String # id da carta
@export var card_cost: int = 1 # custo em energia da carta
@export var card_value: int # atributo da carta, ex: ataque -> value=dano
@export var times_used: int # vezes utilizada ex: ataque duplo, ela é usada 2x
@export_enum("attack", "defense", "technique", "effect") var card_type: String # tipo da carta
@export_enum("single", "multiple") var attack_type: String # tipo de ataque
@export_enum("null", "physical", "status") var damage_type: String # tipo de dano causado
@export_enum("null", "block", "poison", "paralyzed", "bleed", "strength", "weaken", 
"reflect") var status_type: String # status que a carta aplica

var can_click: bool = false


func _ready() -> void:
	box_name_label.text = card_name


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action") and can_click:
		get_tree().call_group("stage", "get_card_in_use", self)


func _on_area_mouse_entered() -> void:
	can_click = true
	position.y = - 50.0


func _on_area_mouse_exited() -> void:
	can_click = false
	position.y = 0
