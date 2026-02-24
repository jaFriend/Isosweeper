extends Node

@export var width: int = 16
@export var height: int = 12
@export var mines: int = 20
@export var tile_scene: PackedScene = preload("res://scenes/tile.tscn")
var grid_level: Grid
var tiles_map: Dictionary

var cells_shown: int
var cells_left: int


func _ready() -> void:
	var start_time: int = Time.get_ticks_usec()
	#var level: Grid = Grid.new(30, 16, 99)
	var pre_generate: bool = false
	grid_level = Grid.new(width, height, mines, pre_generate)
	var end_time: int = Time.get_ticks_usec()
	var total_time_usec: int = end_time - start_time
	var total_time_msec: float = total_time_usec / 1000.0
	print("--- Grid Generation Profile ---")
	print("Total Cells: ", self.width * self.height)
	print("Execution Time: %d μs (%.3f ms)" % [total_time_usec, total_time_msec])
	tiles_map = {}
	_generate_3d_grid()
	
	print("Generated grid")
	
	GameEvents.player_send_vector2i.connect(_mine_grid)
	grid_level.reveal_cell.connect(_reveal_cell)

	cells_shown = 0
	cells_left = width * height - mines

	print("cells_left: %d" % [cells_left])


func _generate_3d_grid() -> void:
	for x in range(width):
		for y in range(height):
			var tile = tile_scene.instantiate()
			var tile_size: float = 2
			var gap_size: float = 0.05
			add_child(tile)
			tile.scale = Vector3(tile_size - gap_size, 1, tile_size - gap_size)
			tile.position = Vector3(tile_size * (x - width / 2 + 1) , 0, tile_size * (y - height / 2 + 1))
			var pos: Vector2i = Vector2i(x,y)
			tile.setup(pos)

			tiles_map[pos] = tile

func _mine_grid(pos: Vector2i):
	grid_level.mine(pos)

func _reveal_cell(pos: Vector2i):
	cells_shown += 1
	print("mines: %d" % [cells_shown])
	var adj_mine_value: Cell = grid_level._get_cell(pos)
	tiles_map[pos].set_mine_value(grid_level.grid[pos.x][pos.y].mines)
	tiles_map[pos]._reveal()
	
	if cells_shown == cells_left:
		#var victory_label: Node = get_node("../Victory")
		#victory_label.visible = true
		print("Victory")
