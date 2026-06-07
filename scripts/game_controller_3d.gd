extends Node3D
class_name GameController3D

@onready var player: PlayerController = $PlayerController
@onready var hud: Control = $CanvasLayer/HUD
@onready var level_gen: LevelGenerator = $LevelGenerator
@onready var ambient_light: DirectionalLight3D = $DirectionalLight3D
@onready var death_screen: Control = $CanvasLayer/DeathScreen
@onready var victory_screen: Control = $CanvasLayer/VictoryScreen

func _ready() -> void:
	GameState.game_over.connect(_on_game_over)
	GameState.reset_game()
	
	# Connect restart buttons
	if death_screen and death_screen.has_node("RestartButton"):
		death_screen.get_node("RestartButton").pressed.connect(_restart)
	if victory_screen and victory_screen.has_node("RestartButton"):
		victory_screen.get_node("RestartButton").pressed.connect(_restart)
	
	# Dark dungeon lighting
	if ambient_light:
		ambient_light.light_energy = 0.3
		ambient_light.light_color = Color(0.2, 0.25, 0.4)
	
	# Player position at start
	if player:
		player.position = Vector3(0, 1, 0)

func _on_game_over(won: bool) -> void:
	if won:
		victory_screen.show()
	else:
		death_screen.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _restart() -> void:
	GameState.reset_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
