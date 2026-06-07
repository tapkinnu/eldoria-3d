extends Node3D

func _ready() -> void:
	await get_tree().create_timer(5.0).timeout
	var img := get_viewport().get_texture().get_image()
	img.save_png("/tmp/eldoria_final.png")
	print("SCREENSHOT_OK:", img.get_width(), "x", img.get_height())
	get_tree().quit()
