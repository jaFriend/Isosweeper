extends Node

@onready var numbers_grid_map: GridMap = $NumbersGridMap
@onready var tiles_grid_map: GridMap = $TilesGridMap
@onready var flags_grid_map: GridMap = $FlagsGridMap
@onready var level_pause_menu = get_node("LevelPauseMenu")
var pause_menu_state: bool = false:
	set(value):
		pause_menu_state = value
		_update_pause_menu_state()

var width: int = 4
var height: int = 4
var mines: int = 1
var pre_generate: bool = false
@export var tile_scene: PackedScene = preload("res://scenes/tile.tscn")
var grid_level: Grid

var cells_shown: int
var cells_left: int
var mines_left: int

var tile_hidden: int
var tile_revealed: int

var flag_hidden: int = -1
var flag_revealed: int

func load_level() -> void:
	var level_info: LevelInfo = LevelManager.get_level()
	self.width = level_info.x
	self.height = level_info.y
	self.mines = level_info.mines
	self.pre_generate = level_info.pre_generate

func _ready() -> void:
	load_level()

	var start_time: int = Time.get_ticks_usec()

	grid_level = Grid.new(width, height, mines, pre_generate)
	var end_time: int = Time.get_ticks_usec()
	var total_time_usec: int = end_time - start_time
	var total_time_msec: float = total_time_usec / 1000.0
	print("--- Grid Generation Profile ---")
	print("Total Cells: ", self.width * self.height)
	print("Execution Time: %d μs (%.3f ms)" % [total_time_usec, total_time_msec])
	_generate_3d_grid()
	print("Generated grid")
	
	GameEvents.player_send_mine_signal.connect(_mine_grid)
	GameEvents.player_send_flag_signal.connect(_flag_grid)
	grid_level.reveal_cell.connect(_reveal_cell)
	grid_level.flag_cell.connect(_flag_cell)
	grid_level.game_over.connect(_on_defeat)
	level_pause_menu.resume_pressed.connect(_resume_game)
	level_pause_menu.exit_pressed.connect(_exit_game)
	
	tile_hidden = 0
	tile_revealed = 1
	flag_revealed = 0
	
	cells_shown = 0
	cells_left = width * height - mines
	mines_left = mines
	var mines_label = get_node("LevelUI/Mines")
	var mines_left_label = get_node("LevelUI/MinesLeft")
	var tiles_left_label = get_node("LevelUI/TilesLeft")
	tiles_left_label.text = str(cells_left)
	mines_label.text = str(mines)
	mines_left_label.text = str(mines_left)

func _generate_3d_grid() -> void:
	tiles_grid_map.cell_scale *= 0.98
	for x in range(self.width):
		for y in range(self.height):
			tiles_grid_map.set_cell_item(Vector3i(x - self.width / 2 + 1, 0, y - self.height / 2 + 1), self.tile_hidden, 0)

func _mine_grid(pos: Vector2i):
	var grid_pos: Vector2i = Vector2i(pos.x + self.width / 2 - 1, pos.y + self.height / 2 - 1)
	grid_level.mine(grid_pos)

func _flag_grid(pos: Vector2i):
	var grid_pos: Vector2i = Vector2i(pos.x + self.width / 2 - 1, pos.y + self.height / 2 - 1)
	grid_level.flag(grid_pos)

func _flag_cell(pos: Vector2i, flag: bool):
	var tiles_left_label = get_node("LevelUI/MinesLeft")
	var grid_map_pos: Vector3i = Vector3i(pos.x - self.width / 2 + 1, 0, pos.y - self.height / 2 + 1)
	if flag:
		flags_grid_map.set_cell_item(grid_map_pos, self.flag_revealed, 10)
		mines_left -= 1
		if mines_left >= 0:
			tiles_left_label.text = str(mines_left)
	else:
		flags_grid_map.set_cell_item(grid_map_pos, self.flag_hidden, 10)
		mines_left += 1
		if mines_left >= 0:
			tiles_left_label.text = str(mines_left)

func _reveal_cell(pos: Vector2i):
	var grid_map_pos: Vector3i = Vector3i(pos.x - self.width / 2 + 1, 0, pos.y - self.height / 2 + 1)
	cells_shown += 1

	numbers_grid_map.set_cell_item(grid_map_pos, grid_level.grid[pos.x][pos.y].mines - 1, 12)
	tiles_grid_map.set_cell_item(grid_map_pos, self.tile_revealed, 0)

	var tiles_left_label = get_node("./LevelUI/TilesLeft")
	tiles_left_label.text = str(cells_left - cells_shown)
	
	if cells_shown == cells_left:
		LevelManager.win()
		GameEvents.is_mouse_captured.emit(false)
		var victory_label: Node = get_node("./Victory")
		victory_label.visible = true
		
		await get_tree().create_timer(2.0).timeout
		_exit_game()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_button"):
		pause_menu_state = not pause_menu_state

func _on_defeat() -> void:
	LevelManager.lose()
	GameEvents.is_mouse_captured.emit(false)
	var defeat_label: Node = get_node("./Defeat")
	defeat_label.visible = true
	await get_tree().create_timer(2.0).timeout
	_exit_game()

func _exit_game() -> void:
	if LevelManager.idx == -1:
		SceneManager.transition("res://scenes/custom_level.tscn")
	else:
		SceneManager.transition("res://scenes/level_menu.tscn")

func _resume_game() -> void:
	pause_menu_state = false

func _update_pause_menu_state() -> void:
	if pause_menu_state:
		GameEvents.is_mouse_captured.emit(false)
		level_pause_menu.visible = true
	else:
		GameEvents.is_mouse_captured.emit(true)
		level_pause_menu.visible = false
