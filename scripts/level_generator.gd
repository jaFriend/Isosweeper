@tool
extends EditorScript

class LevelRequirements:
	var x: int
	var y: int
	var mines: int
	
	func _init(_x: int, _y: int, _mines: int) -> void:
		self.x = _x
		self.y = _y
		self.mines = _mines 
"""
Level Generator Script:
	Generates levels with specific functions and saves it as a PackedByteArray.
	Once used Game will unpack and add it to saved data.
"""
func _run() -> void:
	var levels: Array[LevelInfo]
	var filename: String = "levels.dat"

	add_one_level(levels, create_level_info(8, 8, 3, false))
	
	multi_add_levels_by_range(levels, 
		LevelRequirements.new(8, 8, 6), 
		LevelRequirements.new(12, 12, 20), 29, 10)

	multi_add_levels_by_range(levels, 
		LevelRequirements.new(13, 13, 25), 
		LevelRequirements.new(24, 24, 90), 50, 20)

	multi_add_levels_by_range(levels, 
		LevelRequirements.new(25, 25, 100), 
		LevelRequirements.new(48, 48, 460), 70, 30)

	multi_add_levels_by_range(levels, 
		LevelRequirements.new(50, 50, 525), 
		LevelRequirements.new(100, 100, 2500), 50, 0)
	
	save_levels_data(levels, filename)
	print("Successfully generated 200 levels")

"""
Work to open the saved data back into LevelInfo.

Will be used in future levels UI.

	var file: FileAccess = FileAccess.open(filename, FileAccess.READ)
	var loaded_bytes: PackedByteArray
	if file:
		loaded_bytes = file.get_buffer(file.get_length())
		
	var unpacked_data = bytes_to_var_with_objects(loaded_bytes)
	
	var unpacked_levels: Array[LevelInfo] 
	unpacked_levels.assign(unpacked_data)

"""

func save_levels_data(levels: Array[LevelInfo], filename: String) -> void:
	var buffer: PackedByteArray = var_to_bytes_with_objects(levels)
	var file_path: String = "res://" + filename
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_buffer(buffer)

func create_level_info(x: int, y: int, mines: int, pre_generate: bool) -> LevelInfo:
	var result: LevelInfo = LevelInfo.new()
	result.x = x
	result.y = y
	result.mines = mines
	result.pre_generate = pre_generate

	return result

func add_one_level(levels: Array[LevelInfo], level_info: LevelInfo) -> void:
	levels.append(level_info)

func multi_add_levels_by_range(levels: Array[LevelInfo],
							   start_level: LevelRequirements,
							   end_level: LevelRequirements,
							   levels_amount: int, pre_generate_skip_count: int) -> void:
	if levels_amount < 2:
		return
	for i in range(levels_amount):
		var weight: float = i as float / (levels_amount - 1)
		var pre_generate: bool = false
		
		if pre_generate_skip_count > 0:
			pre_generate_skip_count -= 1
		else:
			pre_generate = true
			
		var level_info: LevelInfo = create_level_info(
			lerp(start_level.x, end_level.x, weight),
			lerp(start_level.y, end_level.y, weight),
			lerp(start_level.mines, end_level.mines, weight),
			pre_generate
		)
		
		add_one_level(levels, level_info)
