extends Label3D
class_name DamageNumber

var lifetime: float = 1.0
var rise_speed: float = 1.5
var fade_timer: float = 0.0

func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	modulate = Color.ORANGE_RED
	outline_size = 2
	font_size = 28
	text = "0"

func start(amount: int) -> void:
	text = "-%d" % amount
	fade_timer = lifetime

func _process(delta: float) -> void:
	position += Vector3.UP * rise_speed * delta
	fade_timer -= delta
	if fade_timer <= 0:
		queue_free()
	else:
		modulate.a = fade_timer / lifetime
