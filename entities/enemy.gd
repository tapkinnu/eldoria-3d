extends CharacterBody3D
class_name EnemyController

@export var max_hp: int = 40
@export var damage: int = 10
@export var attack_range: float = 1.5
@export var move_speed: float = 2.5
@export var attack_cooldown: float = 1.2
@export var is_ranged: bool = false
@export var is_boss: bool = false

@onready var hp: int = max_hp
@onready var player: PlayerController = get_tree().get_first_node_in_group("player")
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var attack_timer: Timer = $AttackTimer
@onready var sprite: Sprite3D = $Sprite3D

var dead: bool = false
var can_attack: bool = true

func _ready() -> void:
	attack_timer.wait_time = attack_cooldown
	attack_timer.timeout.connect(func(): can_attack = true)
	if player:
		nav.target_position = player.global_position

func _physics_process(delta: float) -> void:
	if dead or not player or GameState.mode == GameState.GameMode.DEAD:
		return
	
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	var dist := global_position.distance_to(player.global_position)
	
	if is_ranged:
		if dist > 8.0:
			_navigate_to_player(delta)
		elif dist < 4.0:
			_back_away(delta)
		elif can_attack:
			_ranged_attack()
	else:
		if dist > attack_range:
			_navigate_to_player(delta)
		elif can_attack:
			_melee_attack()

func _navigate_to_player(delta: float) -> void:
	if not nav.is_navigation_finished():
		var next_pos := nav.get_next_path_position()
		var dir := (next_pos - global_position).normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
	else:
		velocity.x = 0
		velocity.z = 0
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	
	move_and_slide()
	
	if player:
		nav.target_position = player.global_position

func _back_away(delta: float) -> void:
	var dir := (global_position - player.global_position).normalized()
	velocity.x = dir.x * move_speed * 0.5
	velocity.z = dir.z * move_speed * 0.5
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	move_and_slide()

func _melee_attack() -> void:
	can_attack = false
	attack_timer.start()
	if player and global_position.distance_to(player.global_position) <= attack_range + 0.5:
		var actual_damage := damage
		if player.is_blocking:
			actual_damage = int(damage * 0.3)
		GameState.damage_player(actual_damage)

func _ranged_attack() -> void:
	can_attack = false
	attack_timer.start()
	if player:
		var proj := preload("res://entities/projectile_3d.tscn").instantiate()
		proj.global_position = global_position + Vector3.UP * 0.5
		proj.target = player
		proj.damage = damage
		get_tree().current_scene.add_child(proj)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0 and not dead:
		_dead()

func _dead() -> void:
	dead = true
	if is_boss:
		GameState.defeat_boss()
		_drop_loot(3)
	else:
		_drop_loot(1)
	queue_free()

func _drop_loot(count: int) -> void:
	for i in range(count):
		var coin := preload("res://entities/coin.tscn").instantiate()
		coin.global_position = global_position + Vector3(randf_range(-0.5, 0.5), 0.2, randf_range(-0.5, 0.5))
		get_tree().current_scene.call_deferred("add_child", coin)
