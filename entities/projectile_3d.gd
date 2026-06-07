extends Area3D
class_name Projectile3D

var target: Node3D
var damage: int = 8
var speed: float = 12.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var timer := Timer.new()
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func _physics_process(delta: float) -> void:
	if target and is_instance_valid(target):
		var dir := (target.global_position - global_position).normalized()
		global_position += dir * speed * delta
	else:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		var actual := damage
		if body.is_blocking:
			actual = int(damage * 0.3)
		GameState.damage_player(actual)
		queue_free()
