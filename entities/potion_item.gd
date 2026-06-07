extends Area3D
class_name PotionItem

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		GameState.add_potion()
		queue_free()
