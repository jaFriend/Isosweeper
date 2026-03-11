extends Node

@onready var numbers_grid_map: GridMap = $NumbersGridMap
@onready var tiles_grid_map: GridMap = $TilesGridMap
@onready var flags_grid_map: GridMap = $FlagsGridMap
@onready var mines_label: Label = $LevelUI/PanelContainer/MarginContainer/HBoxContainer/Mines
@onready var mines_left_label: Label = $LevelUI/PanelContainer/MarginContainer/HBoxContainer/MinesLeft
@onready var tiles_left_label: Label = $LevelUI/PanelContainer/MarginContainer/HBoxContainer/TilesLeft
@onready var level_pause_menu = $LevelPauseMenu
var pause_menu_state: bool = false:
	set(value):
		pause_menu_state = value
		_update_pause_menu_state()

var width: int = 4
var height: int = 4
var mines: int = 1
var pre_generate: bool = false
var time_started: int

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
	grid_level = Grid.new(width, height, mines, pre_generate)
	_generate_3d_grid()

	GameEvents.player_send_mine_signal.connect(_mine_grid)
	GameEvents.player_send_flag_signal.connect(_flag_grid)
	self.grid_level.reveal_cell.connect(_reveal_cell)
	self.grid_level.flag_cell.connect(_flag_cell)
	self.grid_level.game_over.connect(_on_defeat)
	self.level_pause_menu.resume_pressed.connect(_resume_game)
	self.level_pause_menu.exit_pressed.connect(_exit_game)
	
	self.tile_hidden = 0
	self.tile_revealed = 1
	self.flag_revealed = 0
	
	self.cells_shown = 0
	self.cells_left = width * height - mines
	self.mines_left = mines

	self.tiles_left_label.text = str(cells_left)
	self.mines_label.text = str(mines)
	self.mines_left_label.text = str(mines_left)
	time_started = Time.get_ticks_msec()

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

	var grid_map_pos: Vector3i = Vector3i(pos.x - self.width / 2 + 1, 0, pos.y - self.height / 2 + 1)
	if flag:
		self.flags_grid_map.set_cell_item(grid_map_pos, self.flag_revealed, 10)
		self.mines_left -= 1
		if self.mines_left >= 0:
			self.mines_left_label.text = str(self.mines_left)
	else:
		self.flags_grid_map.set_cell_item(grid_map_pos, self.flag_hidden, 10)
		self.mines_left += 1
		if self.mines_left >= 0:
			self.mines_left_label.text = str(self.mines_left)

func _reveal_cell(pos: Vector2i):
	var grid_map_pos: Vector3i = Vector3i(pos.x - self.width / 2 + 1, 0, pos.y - self.height / 2 + 1)
	self.cells_shown += 1

	self.numbers_grid_map.set_cell_item(grid_map_pos, self.grid_level.grid[pos.x][pos.y].mines - 1, 12)
	self.tiles_grid_map.set_cell_item(grid_map_pos, self.tile_revealed, 0)

	self.tiles_left_label.text = str(cells_left - cells_shown)
	
	if cells_shown == cells_left:
		var time: int = (Time.get_ticks_msec() - time_started) / 1000
		LevelManager.win(time)
		GameEvents.is_mouse_captured.emit(false)
		var victory_label: Node = get_node("./Victory")
		victory_label.visible = true
		
		await get_tree().create_timer(2.0).timeout
		_exit_game()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_button"):
		self.pause_menu_state = not self.pause_menu_state

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
	self.pause_menu_state = false

func _update_pause_menu_state() -> void:
	if self.pause_menu_state:
		GameEvents.is_mouse_captured.emit(false)
		self.level_pause_menu.visible = true
	else:
		GameEvents.is_mouse_captured.emit(true)
		self.level_pause_menu.visible = false
