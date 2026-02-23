extends Node

@export var width: int = 32
@export var height: int = 32
@export var mines: int = 400
@export var tile_scene: PackedScene = preload("res://scenes/tile.tscn")
var level: Grid

func _ready() -> void:
	var start_time: int = Time.get_ticks_usec()
	#var level: Grid = Grid.new(30, 16, 99)
	level = Grid.new(width, height, mines)
	var end_time: int = Time.get_ticks_usec()
	var total_time_usec: int = end_time - start_time
	var total_time_msec: float = total_time_usec / 1000.0
	print("--- Grid Generation Profile ---")
	print("Total Cells: ", self.width * self.height)
	print("Execution Time: %d μs (%.3f ms)" % [total_time_usec, total_time_msec])
	var grid = level.grid
	_generate_3d_grid()
	
	start_time = Time.get_ticks_usec()
	level = null
	end_time = Time.get_ticks_usec()
	total_time_usec = end_time - start_time
	total_time_msec = total_time_usec / 1000.0
	print("--- Grid Deletion Profile ---")
	print("Total Cells: ", self.width * self.height)
	print("Execution Time: %d μs (%.3f ms)" % [total_time_usec, total_time_msec])
	

func _generate_3d_grid() -> void:
	for x in range(width):
		for z in range(height):
			
			var tile = tile_scene.instantiate()
			var tile_size: float = 2
			var gap_size: float = 0.05
			tile.scale = Vector3(tile_size - gap_size, 1, tile_size - gap_size)
			add_child(tile)
			tile.position = Vector3(tile_size * (x - width / 2 + 1) , 0, tile_size * (z - height / 2 + 1))
			tile.name = "Tile_%d_%d" % [x, z]
			tile.set_mine_value(level.grid[x][z].mines)
			tile.setup(Vector2i(x,z))
