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

# Persistent upgrades (saved to user://save.cfg)
var hp_upgrades: int = 0
var dmg_upgrades: int = 0
var spd_upgrades: int = 0

const SAVE_PATH := "user://save.cfg"

signal hp_changed(new_hp: int, max_hp: int)
signal coins_changed(new_amount: int)
signal potions_changed(new_amount: int)
signal key_acquired
signal boss_defeated_signal
signal game_over(won: bool)
signal shrine_near_changed(near: bool)

var shrine_near: bool = false:
	set(value):
		shrine_near = value
		shrine_near_changed.emit(value)

func _ready() -> void:
	load_game()

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

func get_upgrade_cost(type: String) -> int:
	var base: int = 0
	match type:
		"hp": base = hp_upgrades
		"dmg": base = dmg_upgrades
		"spd": base = spd_upgrades
	return 10 + base * 5

func can_upgrade(type: String) -> bool:
	return coins >= get_upgrade_cost(type)

func apply_upgrade(type: String) -> bool:
	if not can_upgrade(type):
		return false
	var cost: int = get_upgrade_cost(type)
	coins -= cost
	coins_changed.emit(coins)
	match type:
		"hp":
			hp_upgrades += 1
			player_max_hp += 25
			player_hp = player_max_hp
		"dmg":
			dmg_upgrades += 1
			player_damage += 5
		"spd":
			spd_upgrades += 1
	save_game()
	return true

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("upgrades", "hp", hp_upgrades)
	cfg.set_value("upgrades", "dmg", dmg_upgrades)
	cfg.set_value("upgrades", "spd", spd_upgrades)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		print("Save failed: %d" % err)

func load_game() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return
	hp_upgrades = cfg.get_value("upgrades", "hp", 0)
	dmg_upgrades = cfg.get_value("upgrades", "dmg", 0)
	spd_upgrades = cfg.get_value("upgrades", "spd", 0)
	player_max_hp = 100 + hp_upgrades * 25
	player_damage = 20 + dmg_upgrades * 5
