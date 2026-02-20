class_name Grid

var width: int
var height: int
var mines_count: int
var grid: Array[Array]
var rng: RandomNumberGenerator

const ADJACENT_INDEXES: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1,  0),                  Vector2i(1,  0),
	Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
]

func _init(init_width: int, init_height: int, init_mines_count: int) -> void:
	self.width = init_width
	self.height = init_height
	self.mines_count = init_mines_count
	self.grid = []
	self.rng = RandomNumberGenerator.new()
	self.rng.randomize()
	
	_generate_grid()
	_generate_mines()
	_debug_print_grid()

func _generate_grid() -> void:
	for outer_array in range(self.width):
		var column: Array[Cell] = []
		
		for inner_array in range(self.height):
			column.append(Cell.new())
		
		grid.append(column)

func _cell_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < self.width and pos.y >= 0 and pos.y < self.height

func _get_cell(pos: Vector2i) -> Cell:
	return grid[pos.x][pos.y]

func _get_cell_in_bounds(pos: Vector2i) -> Cell:
	if _cell_in_bounds(pos):
		return grid[pos.x][pos.y]
	return null

func _generate_mines() -> void:
	var i: int = 0
	while i < mines_count:
		var index: Vector2i = Vector2i(rng.randi_range(0, self.width - 1), 
									   rng.randi_range(0, self.height - 1))
		var cell: Cell = _get_cell(index)
		if cell.is_mine():
			continue
		cell.set_as_mine()
		
		for adjacent_index in ADJACENT_INDEXES:
			var adj_cell: Cell = _get_cell_in_bounds(index + adjacent_index)
			if adj_cell and !adj_cell.is_mine():
				adj_cell.increase_mines()
				
		
		i += 1

func _debug_print_grid() -> void:
	for y in range(height):
		var line = ""
		for x in range(width):
			var cell_value = grid[x][y].mines
			if cell_value == 9:
				line += "M "
			else:
				line += str(cell_value) + " "
		print(line)
