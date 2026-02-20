extends Node

func _ready() -> void:
	var start_time: int = Time.get_ticks_usec()
	var level: Grid = Grid.new(30, 16, 99)
	var end_time: int = Time.get_ticks_usec()
	var total_time_usec: int = end_time - start_time
	var total_time_msec: float = total_time_usec / 1000.0
	print("--- Grid Generation Profile ---")
	print("Total Cells: ", 40 * 40)
	print("Execution Time: %d μs (%.3f ms)" % [total_time_usec, total_time_msec])
	var grid = level.grid
