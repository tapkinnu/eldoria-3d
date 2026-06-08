extends Node3D
class_name LevelGenerator

@export var room_count: int = 8
@export var room_size_min: float = 6.0
@export var room_size_max: float = 12.0

var wall_mat: StandardMaterial3D
var floor_mat: StandardMaterial3D
var ceiling_mat: StandardMaterial3D

func _ready() -> void:
	wall_mat = _load_mat("res://assets/textures/wall_texture.png", true)
	floor_mat = _load_mat("res://assets/textures/floor_texture.png", false)
	ceiling_mat = _load_mat("res://assets/textures/ceiling_texture.png", false)
	_generate_dungeon()

func _load_mat(path: String, vertical: bool) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(path)
	mat.uv1_scale = Vector3(2, 2, 1)
	return mat

func _generate_dungeon() -> void:
	var rooms: Array[Dictionary] = []
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	# Start room
	rooms.append({"pos": Vector3.ZERO, "size": Vector3(8, 4, 8), "type": "start"})
	
	# Generate rooms
	for i in range(room_count - 1):
		var prev: Dictionary = rooms[-1]
		var dir := Vector3.FORWARD.rotated(Vector3.UP, rng.randf_range(0, TAU)) as Vector3
		var size := Vector3(
			rng.randf_range(room_size_min, room_size_max),
			4.0,
			rng.randf_range(room_size_min, room_size_max)
		) as Vector3
		var dist: float = size.x + prev["size"].x
		var pos: Vector3 = prev["pos"] + dir * dist * 0.7
		
		var room_type := "normal"
		if i == room_count - 2:
			room_type = "boss"
		
		rooms.append({"pos": pos, "size": size, "type": room_type})
		_build_corridor(prev["pos"], pos)
	
	# Build rooms
	for room in rooms:
		_build_room(room["pos"], room["size"], room["type"])

func _build_room(pos: Vector3, size: Vector3, type: String) -> void:
	var room := Node3D.new()
	room.name = "Room_%s" % type
	add_child(room)
	
	# Floor
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(size.x, 0.2, size.z)
	var floor_mi := MeshInstance3D.new()
	floor_mi.mesh = floor_mesh
	floor_mi.material_override = floor_mat
	floor_mi.position = pos + Vector3(0, -0.1, 0)
	room.add_child(floor_mi)
	
	# Ceiling
	var ceil_mesh := BoxMesh.new()
	ceil_mesh.size = Vector3(size.x, 0.2, size.z)
	var ceil_mi := MeshInstance3D.new()
	ceil_mi.mesh = ceil_mesh
	ceil_mi.material_override = ceiling_mat
	ceil_mi.position = pos + Vector3(0, size.y + 0.1, 0)
	room.add_child(ceil_mi)
	
	# Walls (4 sides)
	var half_x := size.x / 2.0
	var half_z := size.z / 2.0
	var half_y := size.y / 2.0
	var wall_thickness := 0.3
	
	# North wall
	_build_wall(room, pos + Vector3(0, half_y, -half_z - wall_thickness/2),
		Vector3(size.x, size.y, wall_thickness))
	# South wall
	_build_wall(room, pos + Vector3(0, half_y, half_z + wall_thickness/2),
		Vector3(size.x, size.y, wall_thickness))
	# East wall
	_build_wall(room, pos + Vector3(half_x + wall_thickness/2, half_y, 0),
		Vector3(wall_thickness, size.y, size.z))
	# West wall
	_build_wall(room, pos + Vector3(-half_x - wall_thickness/2, half_y, 0),
		Vector3(wall_thickness, size.y, size.z))
	
	# Static body for collision
	var sb := StaticBody3D.new()
	room.add_child(sb)
	
	# Floor collision
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(size.x, 0.2, size.z)
	var floor_col := CollisionShape3D.new()
	floor_col.shape = floor_shape
	floor_col.position = pos + Vector3(0, -0.1, 0)
	sb.add_child(floor_col)
	
	# Wall collisions
	var wall_shapes := [
		{ "pos": pos + Vector3(0, half_y, -half_z - wall_thickness/2),
		  "size": Vector3(size.x, size.y, wall_thickness) },
		{ "pos": pos + Vector3(0, half_y, half_z + wall_thickness/2),
		  "size": Vector3(size.x, size.y, wall_thickness) },
		{ "pos": pos + Vector3(half_x + wall_thickness/2, half_y, 0),
		  "size": Vector3(wall_thickness, size.y, size.z) },
		{ "pos": pos + Vector3(-half_x - wall_thickness/2, half_y, 0),
		  "size": Vector3(wall_thickness, size.y, size.z) },
	]
	
	for ws in wall_shapes:
		var ws_shape := BoxShape3D.new()
		ws_shape.size = ws["size"]
		var ws_col := CollisionShape3D.new()
		ws_col.shape = ws_shape
		ws_col.position = ws["pos"]
		sb.add_child(ws_col)
	
	# Add content based on type
	if type == "start":
		_add_torch(room, pos + Vector3(-half_x + 0.5, 2.5, 0))
		_add_torch(room, pos + Vector3(half_x - 0.5, 2.5, 0))
		_add_shrine(room, pos + Vector3(0, 0, half_z - 1.5))
	elif type == "boss":
		_add_boss(room, pos)
		_add_portal(room, pos + Vector3(0, 0, half_z - 1.0))
	else:
		_add_enemies(room, pos, size)
		_add_loot(room, pos, size)
		_add_torch(room, pos + Vector3(0, 2.5, -half_z + 0.5))

func _build_wall(parent: Node, pos: Vector3, size: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = wall_mat
	mi.position = pos
	parent.add_child(mi)

func _build_corridor(from: Vector3, to: Vector3) -> void:
	var mid := (from + to) / 2.0
	var dist := from.distance_to(to)
	var dir := (to - from).normalized()
	var perp := dir.cross(Vector3.UP).normalized()
	
	var corridor := Node3D.new()
	corridor.name = "Corridor"
	add_child(corridor)
	
	# Floor
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(2.0, 0.2, dist)
	var floor_mi := MeshInstance3D.new()
	floor_mi.mesh = floor_mesh
	floor_mi.material_override = floor_mat
	floor_mi.position = mid + Vector3(0, -0.1, 0)
	corridor.add_child(floor_mi)
	
	# Walls
	_build_wall(corridor, mid + perp * 1.15 + Vector3(0, 2, 0), Vector3(0.3, 4, dist))
	_build_wall(corridor, mid - perp * 1.15 + Vector3(0, 2, 0), Vector3(0.3, 4, dist))
	
	# Collision
	var sb := StaticBody3D.new()
	corridor.add_child(sb)
	
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(2.0, 0.2, dist)
	var floor_col := CollisionShape3D.new()
	floor_col.shape = floor_shape
	floor_col.position = mid + Vector3(0, -0.1, 0)
	sb.add_child(floor_col)
	
	var w1_shape := BoxShape3D.new()
	w1_shape.size = Vector3(0.3, 4, dist)
	var w1_col := CollisionShape3D.new()
	w1_col.shape = w1_shape
	w1_col.position = mid + perp * 1.15 + Vector3(0, 2, 0)
	sb.add_child(w1_col)
	
	var w2_shape := BoxShape3D.new()
	w2_shape.size = Vector3(0.3, 4, dist)
	var w2_col := CollisionShape3D.new()
	w2_col.shape = w2_shape
	w2_col.position = mid - perp * 1.15 + Vector3(0, 2, 0)
	sb.add_child(w2_col)

func _add_enemies(parent: Node, room_pos: Vector3, room_size: Vector3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var count := rng.randi_range(1, 3)
	for i in range(count):
		var is_ranged := rng.randf() > 0.6
		var enemy: EnemyController
		if is_ranged:
			enemy = preload("res://entities/goblin_archer.tscn").instantiate()
		else:
			enemy = preload("res://entities/skeleton_warrior.tscn").instantiate()
		var offset := Vector3(
			rng.randf_range(-room_size.x * 0.3, room_size.x * 0.3),
			0,
			rng.randf_range(-room_size.z * 0.3, room_size.z * 0.3)
		)
		enemy.position = room_pos + offset
		parent.add_child(enemy)

func _add_loot(parent: Node, room_pos: Vector3, room_size: Vector3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if rng.randf() < 0.5:
		var potion := preload("res://entities/potion.tscn").instantiate()
		potion.position = room_pos + Vector3(rng.randf_range(-1, 1), 0.2, rng.randf_range(-1, 1))
		parent.add_child(potion)

func _add_boss(parent: Node, pos: Vector3) -> void:
	var boss: EnemyController = preload("res://entities/skeleton_boss.tscn").instantiate()
	boss.position = pos
	parent.add_child(boss)
	
	var key := preload("res://entities/key.tscn").instantiate()
	key.position = pos + Vector3(0, 0.3, 2)
	parent.add_child(key)

func _add_portal(parent: Node, pos: Vector3) -> void:
	var portal: Portal = preload("res://entities/portal.tscn").instantiate()
	portal.position = pos
	parent.add_child(portal)

func _add_shrine(parent: Node, pos: Vector3) -> void:
	var shrine: UpgradeShrine = preload("res://entities/upgrade_shrine.tscn").instantiate()
	shrine.position = pos
	parent.add_child(shrine)

func _add_torch(parent: Node, pos: Vector3) -> void:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_energy = 2.0
	light.omni_range = 12.0
	light.light_color = Color.ORANGE_RED
	parent.add_child(light)
	
	var torch_sprite := Sprite3D.new()
	torch_sprite.texture = preload("res://assets/textures/wall_torch.png")
	torch_sprite.position = pos
	torch_sprite.pixel_size = 0.015
	torch_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(torch_sprite)
