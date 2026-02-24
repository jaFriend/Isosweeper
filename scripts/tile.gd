extends Node

enum TileState { HIDDEN, REVEALED, EXPLODED, FLAGGED }
var state: TileState = TileState.HIDDEN:
	set(value):
		state = value
		_update_visual()


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
var adj_mines_value: int

func setup(coords: Vector2i):
	grid_coords = coords

func get_tile_coordinates() -> Vector2i:
	return grid_coords

func set_mine_value(value :int) -> void:
	if value == 9:
		return
	self.adj_mines_value = value

func _update_visual() -> void:
	match state:
		TileState.REVEALED:
			var block: Node = get_node("Block")
			var block_revealed: Node = get_node("Block_revealed")
			block_revealed.visible = true
			block.visible = false
			if self.adj_mines_value == 0:
				return
			
			var adj_mines: Node = get_node("AdjacentMines")
			adj_mines.text = str(self.adj_mines_value)
			adj_mines.modulate = MINE_COLORS[self.adj_mines_value]
			adj_mines.visible = true

func _reveal() -> void:
	self.state = TileState.REVEALED
