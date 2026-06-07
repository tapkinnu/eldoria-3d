extends Control

func _ready() -> void:
	if has_node("RestartButton"):
		$RestartButton.pressed.connect(_restart)

func _restart() -> void:
	GameState.reset_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
