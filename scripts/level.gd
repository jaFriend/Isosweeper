extends Node


@onready var level_pause_menu = get_node("../LevelPauseMenu")
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
var tiles_map: Dictionary

var cells_shown: int
var cells_left: int
var mines_left: int

func load_level() -> void:
	if LevelManager.level:
		self.width = LevelManager.level.x
		self.height = LevelManager.level.y
		self.mines = LevelManager.level.mines
		self.pre_generate = LevelManager.level.pre_generate

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
	tiles_map = {}
	_generate_3d_grid()
	
	print("Generated grid")
	
	GameEvents.player_send_mine_signal.connect(_mine_grid)
	GameEvents.player_send_flag_signal.connect(_flag_grid)
	grid_level.reveal_cell.connect(_reveal_cell)
	grid_level.flag_cell.connect(_flag_cell)
	grid_level.game_over.connect(_on_defeat)
	level_pause_menu.resume_pressed.connect(_resume_game)
	level_pause_menu.exit_pressed.connect(_exit_game)

	cells_shown = 0
	cells_left = width * height - mines
	mines_left = mines
	var mines_label = get_node("../LevelUI/Mines")
	var mines_left_label = get_node("../LevelUI/MinesLeft")
	var tiles_left_label = get_node("../LevelUI/TilesLeft")
	tiles_left_label.text = str(cells_left)
	mines_label.text = str(mines)
	mines_left_label.text = str(mines_left)

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
	
func _flag_grid(pos: Vector2i):
	grid_level.flag(pos)

func _flag_cell(pos: Vector2i, flag: bool):
	var tiles_left_label = get_node("../LevelUI/MinesLeft")
	if flag:
		mines_left -= 1
		if mines_left >= 0:
			tiles_left_label.text = str(mines_left)
	else:
		mines_left += 1
		if mines_left >= 0:
			tiles_left_label.text = str(mines_left)
	tiles_map[pos]._flag(flag)

func _reveal_cell(pos: Vector2i):
	cells_shown += 1
	print("mines: %d" % [cells_shown])
	var adj_mine_value: Cell = grid_level._get_cell(pos)
	tiles_map[pos].set_mine_value(grid_level.grid[pos.x][pos.y].mines)
	tiles_map[pos]._reveal()

	var tiles_left_label = get_node("../LevelUI/TilesLeft")
	tiles_left_label.text = str(cells_left - cells_shown)
	
	if cells_shown == cells_left:
		GameEvents.is_mouse_captured.emit(false)
		var victory_label: Node = get_node("../Victory")
		victory_label.visible = true
		
		await get_tree().create_timer(2.0).timeout
		LevelManager.level_completed = true
		_exit_game()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_button"):
		pause_menu_state = not pause_menu_state

func _on_defeat() -> void:
	GameEvents.is_mouse_captured.emit(false)
	var defeat_label: Node = get_node("../Defeat")
	defeat_label.visible = true
	await get_tree().create_timer(2.0).timeout
	_exit_game()

func _exit_game() -> void:
	get_tree().change_scene_to_file("res://scenes/level_menu.tscn")

func _resume_game() -> void:
	pause_menu_state = false

func _update_pause_menu_state() -> void:
	if pause_menu_state:
		GameEvents.is_mouse_captured.emit(false)
		level_pause_menu.visible = true
	else:
		GameEvents.is_mouse_captured.emit(true)
		level_pause_menu.visible = false
