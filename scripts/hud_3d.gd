extends Control
class_name HUD3D

@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/HPBar
@onready var hp_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/HPLabel
@onready var coin_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/CoinLabel
@onready var potion_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/PotionLabel
@onready var key_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer2/KeyIcon
@onready var boss_label: Label = $MarginContainer/VBoxContainer/HBoxContainer3/BossLabel
@onready var crosshair: ColorRect = $Crosshair

func _ready() -> void:
	GameState.hp_changed.connect(_update_hp)
	GameState.coins_changed.connect(_update_coins)
	GameState.potions_changed.connect(_update_potions)
	GameState.key_acquired.connect(_show_key)
	GameState.boss_defeated_signal.connect(_show_victory_ready)
	
	_update_hp(GameState.player_hp, GameState.player_max_hp)
	_update_coins(GameState.coins)
	_update_potions(GameState.potions)
	key_icon.modulate.a = 0.3
	boss_label.text = "Defeat the Skeleton Boss!"

func _update_hp(hp: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "HP: %d/%d" % [hp, max_hp]

func _update_coins(coins: int) -> void:
	coin_label.text = "Coins: %d" % coins

func _update_potions(potions: int) -> void:
	potion_label.text = "Potions: %d (E to use)" % potions

func _show_key() -> void:
	key_icon.modulate.a = 1.0
	boss_label.text = "Key acquired! Find the Portal!"

func _show_victory_ready() -> void:
	boss_label.text = "Boss defeated! Escape through the Portal!"
	boss_label.modulate = Color.GREEN
