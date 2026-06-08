extends SceneTree

func _init() -> void:
	var main: PackedScene = load("res://scenes/main.tscn")
	if main:
		var instance := main.instantiate()
		root.add_child(instance)
	RenderingServer.frame_post_draw.connect(_on_frame)

var _frames: int = 0
func _on_frame() -> void:
	_frames += 1
	if _frames < 6:
		return
	var img: Image = root.get_viewport().get_texture().get_image()
	if img and img.get_width() > 0:
		img.save_png("res://artifacts/screenshot.png")
		print("Screenshot saved to res://artifacts/screenshot.png")
	else:
		print("No image captured")
		var fallback := Image.create(1280, 720, false, Image.FORMAT_RGB8)
		fallback.fill(Color.BLACK)
		fallback.save_png("res://artifacts/screenshot.png")
		print("Saved fallback blank")
	quit()
