extends Control
class_name UpgradePanel

@onready var hp_btn: Button = $Panel/VBox/HpUpgrade
@onready var dmg_btn: Button = $Panel/VBox/DmgUpgrade
@onready var spd_btn: Button = $Panel/VBox/SpdUpgrade
@onready var close_btn: Button = $Panel/VBox/CloseButton

@onready var hp_cost: Label = $Panel/VBox/HpUpgrade/CostLabel
@onready var dmg_cost: Label = $Panel/VBox/DmgUpgrade/CostLabel
@onready var spd_cost: Label = $Panel/VBox/SpdUpgrade/CostLabel

var click_sfx: AudioStreamPlayer

func _ready() -> void:
	visible = false
	GameState.shrine_near_changed.connect(_on_shrine_near)
	
	click_sfx = AudioStreamPlayer.new()
	add_child(click_sfx)
	
	hp_btn.pressed.connect(_buy.bind("hp"))
	dmg_btn.pressed.connect(_buy.bind("dmg"))
	spd_btn.pressed.connect(_buy.bind("spd"))
	close_btn.pressed.connect(_close)

func _on_shrine_near(near: bool) -> void:
	visible = near
	if near:
		_refresh()

func _refresh() -> void:
	hp_cost.text = "Cost: %d coins" % GameState.get_upgrade_cost("hp")
	dmg_cost.text = "Cost: %d coins" % GameState.get_upgrade_cost("dmg")
	spd_cost.text = "Cost: %d coins" % GameState.get_upgrade_cost("spd")
	hp_btn.disabled = not GameState.can_upgrade("hp")
	dmg_btn.disabled = not GameState.can_upgrade("dmg")
	spd_btn.disabled = not GameState.can_upgrade("spd")

func _buy(type: String) -> void:
	if GameState.apply_upgrade(type):
		_play_sfx("res://assets/audio/sfx/upgrade_apply.wav")
		_refresh()
		var hud: HUD3D = get_parent().get_node("HUD")
		if hud:
			hud._update_hp(GameState.player_hp, GameState.player_max_hp)
			
func _close() -> void:
	visible = false

func _play_sfx(path: String) -> void:
	if ResourceLoader.exists(path):
		click_sfx.stream = load(path)
		click_sfx.play()
