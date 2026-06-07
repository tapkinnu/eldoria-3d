extends Node
class_name GameStateClass

enum GameMode { EXPLORING, COMBAT, DEAD, VICTORY }

var mode: GameMode = GameMode.EXPLORING
var player_hp: int = 100
var player_max_hp: int = 100
var player_damage: int = 20
var has_key: bool = false
var boss_defeated: bool = false
var coins: int = 0
var potions: int = 0

var level: int = 1

signal hp_changed(new_hp: int, max_hp: int)
signal coins_changed(new_amount: int)
signal potions_changed(new_amount: int)
signal key_acquired
signal boss_defeated_signal
signal game_over(won: bool)

func damage_player(amount: int) -> void:
	player_hp = max(0, player_hp - amount)
	hp_changed.emit(player_hp, player_max_hp)
	if player_hp <= 0:
		mode = GameMode.DEAD
		game_over.emit(false)

func heal_player(amount: int) -> void:
	player_hp = min(player_max_hp, player_hp + amount)
	hp_changed.emit(player_hp, player_max_hp)

func add_potion() -> void:
	potions += 1
	potions_changed.emit(potions)

func use_potion() -> bool:
	if potions > 0 and player_hp < player_max_hp:
		potions -= 1
		heal_player(25)
		potions_changed.emit(potions)
		return true
	return false

func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins)

func acquire_key() -> void:
	has_key = true
	key_acquired.emit()

func defeat_boss() -> void:
	boss_defeated = true
	boss_defeated_signal.emit()

func reset_game() -> void:
	mode = GameMode.EXPLORING
	player_hp = player_max_hp
	player_damage = 20
	has_key = false
	boss_defeated = false
	coins = 0
	potions = 0
	level = 1
