extends Sprite2D
class_name BaseEffect

@export_category("Objetos")
@export var animation: AnimationPlayer


func _ready() -> void:
	animation.play("effect")


func _on_animation_animation_finished(anim_name: StringName) -> void:
	queue_free()
