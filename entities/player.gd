extends CharacterBody3D
class_name PlayerController

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.003

@onready var camera: Camera3D = $Camera3D
@onready var attack_ray: RayCast3D = $AttackRay
@onready var attack_cooldown: Timer = $AttackCooldown

var can_attack: bool = true
var is_blocking: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	attack_cooldown.timeout.connect(func(): can_attack = true)
	GameState.hp_changed.connect(_on_hp_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2.2, PI / 2.2)
	
	if event.is_action_pressed("interact"):
		GameState.use_potion()

func _physics_process(delta: float) -> void:
	if GameState.mode != GameState.GameMode.EXPLORING and GameState.mode != GameState.GameMode.COMBAT:
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	
	move_and_slide()
	
	is_blocking = Input.is_action_pressed("block")
	
	if Input.is_action_pressed("attack") and can_attack and not is_blocking:
		_perform_attack()

func _perform_attack() -> void:
	can_attack = false
	attack_cooldown.start(0.5)
	
	attack_ray.force_raycast_update()
	if attack_ray.is_colliding():
		var collider := attack_ray.get_collider()
		if collider is EnemyController:
			collider.take_damage(GameState.player_damage)

func _on_hp_changed(_hp: int, _max: int) -> void:
	if GameState.player_hp <= 0:
		GameState.mode = GameState.GameMode.DEAD
