extends GridMap

var highlight_node: Node3D = null

"""
Work from Thanh Vo's commit
"""
func create_highlight_instance() -> void:
	highlight_node = Node3D.new()
	highlight_node.top_level = true 
	add_child(highlight_node)
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0, 0, 1)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var s := cell_size * 2
	var w := s.x * 0.5
	var d := s.z * 0.5
	var t := 0.03
	
	var borders = [
		[Vector3(0, 0, d),  Vector3(s.x, 0.05, t)],
		[Vector3(0, 0, -d), Vector3(s.x, 0.05, t)],
		[Vector3(w, 0, 0),  Vector3(t, 0.05, s.z)],
		[Vector3(-w, 0, 0), Vector3(t, 0.05, s.z)],
	]
	
	for border in borders:
		var b := MeshInstance3D.new()
		b.mesh = BoxMesh.new()
		b.material_override = mat
		b.position = border[0]
		b.scale = border[1]
		highlight_node.add_child(b)

func update_selection(map_pos: Vector3i) -> void:
	if highlight_node == null:
		create_highlight_instance()

	if get_cell_item(map_pos) != INVALID_CELL_ITEM:
		var local_center = map_to_local(map_pos)
		highlight_node.global_position = to_global(local_center) + Vector3(0, 1, 0)
