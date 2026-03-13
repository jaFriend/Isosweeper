class_name Grid

var width: int
var height: int
var mines_count: int
var grid: Array[Array]
var rng: RandomNumberGenerator
var late_generation: bool

signal reveal_cell(pos: Vector2i)
signal flag_cell(pos: Vector2i, flag: bool)
signal game_over

const ADJACENT_INDEXES: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1,  0),                  Vector2i(1,  0),
	Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
]

func _init(init_width: int, init_height: int, init_mines_count: int, pre_generate: bool) -> void:
	self.width = init_width
	self.height = init_height
	self.mines_count = init_mines_count
	self.grid = []
	self.rng = RandomNumberGenerator.new()
	self.rng.randomize()
	self.late_generation = true
	
	_generate_grid()
	
	if pre_generate:
		self.late_generation = false
		_generate_mines()
	#_debug_print_grid()

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
		if cell.is_mine() or cell.is_revealed:
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

func flag(pos: Vector2i) -> void:
	var cell: Cell = _get_cell_in_bounds(pos)
	if not cell or cell.mined():
		return
	cell.toggle_flagged()
	flag_cell.emit(pos, cell.flagged())

func mine(pos: Vector2i, tree: SceneTree) -> void:
	var first_cell: Cell = _get_cell_in_bounds(pos)
	if not first_cell or first_cell.flagged() or first_cell.mined():
		return
	if first_cell.is_mine():
		game_over.emit()
		return

	var visited = {}
	var current_layer: Array[Vector2i] = [pos]
	visited[pos] = true

	while !current_layer.is_empty():
		if not is_instance_valid(tree):
			return
		var next_layer: Array[Vector2i] = []
		
		for cell_pos in current_layer:
			var cell: Cell = _get_cell_in_bounds(cell_pos)
			if not cell or cell.mined() or cell.flagged():
				continue
				
			cell.mine()
			if self.late_generation:
				self.late_generation = false
				_generate_mines()
			reveal_cell.emit(cell_pos)
			if cell.mines == 0:
				for adjacent_index in ADJACENT_INDEXES:
					var adj_pos: Vector2i = cell_pos + adjacent_index
					var adj_cell: Cell = _get_cell_in_bounds(adj_pos)
					if adj_cell and not adj_cell.is_mine() and not adj_cell.is_revealed and not visited.has(adj_cell):
						next_layer.push_back(adj_pos)
						visited[adj_pos] = true
		current_layer = next_layer

		if !current_layer.is_empty():
			await tree.create_timer(0.1).timeout
