extends Area3D
class_name KeyItem

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		GameState.acquire_key()
		queue_free()
