extends Node

var _frames := 0
var _target := "/home/ganomix/projects/eldoria-3d/artifacts/screenshot.png"

func _ready() -> void:
	RenderingServer.frame_post_draw.connect(_on_frame_post_draw)

func _on_frame_post_draw() -> void:
	_frames += 1
	if _frames < 6:
		return
	var img := get_viewport().get_texture().get_image()
	if img and img.get_width() > 0:
		img.save_png(_target)
		print("Screenshot saved to ", _target)
		get_tree().quit()
	else:
		print("No viewport image")
		get_tree().quit()
