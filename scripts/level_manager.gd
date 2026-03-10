extends Node

var levels: Array[LevelInfo]
var idx: int
var completed_levels: int
var level_completed: bool = 0
var custom_level_info: LevelInfo

func _ready() -> void:
	open_levels()

func win() -> void:
	if self.idx == -1:
		return
	self.level_completed = true
	self.unlock_level()

func lose() -> void:
	if self.idx == -1:
		return
	self.level_completed = false

func load_level(index: int) -> void:
	self.idx = index
	self.level_completed = false
	SceneManager.transition("res://scenes/level.tscn")

func unlock_level() -> void:
	if LevelManager.level_completed and LevelManager.idx == LevelManager.completed_levels:
		LevelManager.level_completed = false
		LevelManager.completed_levels += 1

func get_level() -> LevelInfo:
	if self.idx == -1:
		return custom_level_info
	return levels[idx]

func open_levels() -> bool:
	var file: FileAccess = FileAccess.open("res://levels.dat", FileAccess.READ)
	var loaded_bytes: PackedByteArray
	if file:
		loaded_bytes = file.get_buffer(file.get_length())
	else:
		return false

	var unpacked_data = bytes_to_var_with_objects(loaded_bytes)
	
	self.levels.assign(unpacked_data)
	return true

func load_custom_level(level_info: LevelInfo) -> void:
	self.custom_level_info = level_info
	self.idx = -1
	SceneManager.transition("res://scenes/level.tscn")
