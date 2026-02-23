extends Node

const MINE_COLORS: Array = [
	Color(1,1,1),
	Color(0, 0, 1),
	Color(0, 0.5, 0),
	Color(1, 0, 0),
	Color(0, 0, 0.5),
	Color(0.5, 0, 0),
	Color(0, 0.5, 0.5),
	Color(0, 0, 0),
	Color(0.5, 0.5, 0.5),
	Color(1,1,1)
]

var grid_coords: Vector2i

func setup(coords: Vector2i):
	grid_coords = coords

func get_tile_coordinates() -> Vector2i:
	return grid_coords

func set_mine_value(value :int) -> void:
	var mine_label: Node = get_node("MineLabel")
	mine_label.text = str(value)
	mine_label.modulate = MINE_COLORS[value]
