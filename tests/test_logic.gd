extends SceneTree

const GameStateClass = preload("res://autoload/game_state.gd")

func _init() -> void:
	print("--- Eldoria Logic Tests ---")
	_run_tests()
	print("--- Done ---")
	quit()

func _run_tests() -> void:
	var State := GameStateClass.new()
	
	# Test GameState damage/heal
	State.reset_game()
	assert(State.player_hp == 100, "HP should reset to 100")
	
	State.damage_player(30)
	assert(State.player_hp == 70, "HP should be 70 after 30 dmg")
	assert(State.mode == State.GameMode.EXPLORING, "Mode should stay exploring")
	
	State.heal_player(20)
	assert(State.player_hp == 90, "HP should be 90 after 20 heal")
	
	# Test potion usage
	State.potions = 0
	assert(not State.use_potion(), "use_potion should fail with zero potions")
	
	State.add_potion()
	assert(State.potions == 1, "Potions should be 1")
	State.player_hp = 50
	assert(State.use_potion(), "use_potion should succeed")
	assert(State.player_hp == 75, "HP should be 75 after potion")
	
	# Test kill triggers game over
	State.reset_game()
	State.damage_player(200)
	assert(State.player_hp == 0, "HP should clamp to 0")
	assert(State.mode == State.GameMode.DEAD, "Mode should be DEAD")
	
	# Test key/boss/portal flow
	State.reset_game()
	assert(not State.has_key, "Should not have key initially")
	State.acquire_key()
	assert(State.has_key, "Should have key after acquire")
	
	assert(not State.boss_defeated, "Boss not defeated initially")
	State.defeat_boss()
	assert(State.boss_defeated, "Boss should be defeated")
	
	# Test coins
	State.add_coin()
	assert(State.coins == 1, "Should have 1 coin")
	
	# Test upgrade system
	State.coins = 5
	assert(not State.can_upgrade("hp"), "Should not afford upgrade with 5 coins")
	State.coins = 15
	assert(State.can_upgrade("hp"), "Should afford upgrade with 15 coins")
	assert(State.apply_upgrade("hp"), "apply_upgrade hp should succeed")
	assert(State.hp_upgrades == 1, "hp_upgrades should be 1")
	assert(State.player_max_hp == 125, "max hp should be 125 after upgrade")
	assert(State.player_hp == 125, "hp should refill to 125")
	assert(State.coins == 5, "coins should be 5 (15 - 10)")
	
	# Test damage upgrade
	State.coins = 20
	assert(State.apply_upgrade("dmg"), "apply_upgrade dmg should succeed")
	assert(State.dmg_upgrades == 1, "dmg_upgrades should be 1")
	assert(State.player_damage == 25, "damage should be 25")
	
	# Test increasing cost
	assert(State.get_upgrade_cost("hp") == 15, "Second hp upgrade should cost 15")
	
	# Test save/load roundtrip
	State.save_game()
	var State2 := GameStateClass.new()
	State2.load_game()
	assert(State2.hp_upgrades == 1, "Loaded hp_upgrades should be 1")
	assert(State2.dmg_upgrades == 1, "Loaded dmg_upgrades should be 1")
	assert(State2.player_max_hp == 125, "Loaded max hp should be 125")
	assert(State2.player_damage == 25, "Loaded damage should be 25")
	
	print("ALL TESTS PASSED")
