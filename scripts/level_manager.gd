extends Node

var levels: Array[LevelInfo]
var levels_time: Array[int]
var idx: int
var menu_scroll_pos: int
var completed_levels: int
var completed_level_time: int
var level_completed: bool = 0
var custom_level_info: LevelInfo

const CUSTOM_LEVEL: int = -1
func _ready() -> void:
	open_levels()

func win(time: int) -> void:
	if self.idx == self.CUSTOM_LEVEL:
		return
	self.level_completed = true
	self.completed_level_time = time
	if self.idx < self.completed_levels and time < self.levels_time[idx]:
		self.levels_time[idx] = time
	self.unlock_level()

func lose() -> void:
	if self.idx == self.CUSTOM_LEVEL:
		return
	self.level_completed = false

func load_level(index: int) -> void:
	self.idx = index
	self.level_completed = false
	self.completed_level_time = 0
	SceneManager.transition(SceneManager.SCENES.LEVEL)

func unlock_level() -> void:
	if self.level_completed and self.idx == self.completed_levels:
		self.level_completed = false
		self.levels_time.append(self.completed_level_time)
		self.completed_level_time = 0
		self.completed_levels += 1

func get_level() -> LevelInfo:
	if self.idx == self.CUSTOM_LEVEL:
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
	self.idx = self.CUSTOM_LEVEL
	SceneManager.transition(SceneManager.SCENES.LEVEL)

func save_scroll_pos(value: int):
	self.menu_scroll_pos = value
