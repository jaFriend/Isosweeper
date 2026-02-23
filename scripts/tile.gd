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
	var adj_mines: Node = get_node("AdjacentMines")
	adj_mines.mesh = adj_mines.mesh.duplicate()
	adj_mines.mesh.text = str(value)
	adj_mines.mesh.material = adj_mines.mesh.material.duplicate()
	adj_mines.mesh.material.albedo_color = MINE_COLORS[value]
