extends Area3D
class_name Portal

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		if GameState.boss_defeated:
			GameState.mode = GameState.GameMode.VICTORY
			GameState.game_over.emit(true)
