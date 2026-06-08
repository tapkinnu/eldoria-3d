extends Control

@onready var click_sfx: AudioStreamPlayer = $UISFX

func _ready() -> void:
	$VBoxContainer/StartButton.pressed.connect(_on_start)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit)
	$VBoxContainer/StartButton.mouse_entered.connect(_play_click)
	$VBoxContainer/QuitButton.mouse_entered.connect(_play_click)

func _play_click() -> void:
	if click_sfx and ResourceLoader.exists("res://assets/audio/sfx/ui_click.wav"):
		click_sfx.stream = load("res://assets/audio/sfx/ui_click.wav")
		click_sfx.play()

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit() -> void:
	get_tree().quit()
