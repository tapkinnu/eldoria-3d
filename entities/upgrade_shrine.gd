extends Area3D
class_name UpgradeShrine

@onready var sprite: Sprite3D = $Sprite3D
@onready var light: OmniLight3D = $OmniLight3D

var player_near: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if sprite:
		sprite.texture = load("res://assets/generated/upgrade_shrine.png")
		sprite.pixel_size = 0.015
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	if light:
		light.light_color = Color(0.2, 0.6, 1.0)
		light.light_energy = 3.0
		light.omni_range = 6.0

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		player_near = true
		GameState.shrine_near = true

func _on_body_exited(body: Node3D) -> void:
	if body is PlayerController:
		player_near = false
		GameState.shrine_near = false
