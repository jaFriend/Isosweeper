extends Node

@onready var numbers_grid_map: GridMap = $NumbersGridMap
@onready var tiles_grid_map: GridMap = $TilesGridMap
@onready var flags_grid_map: GridMap = $FlagsGridMap
@onready var tiles_collision: CollisionShape3D = $TilesBody/TilesCollision
@onready var level_pause_menu = $LevelPauseMenu
@onready var level_ui = $LevelUI
@onready var victory_label: Node = $Victory
@onready var defeat_label: Node = $Defeat

var pause_menu_state: bool = false:
	set(value):
		pause_menu_state = value
		_update_pause_menu_state()

var width: int = 4
var height: int = 4
var mines: int = 1
var pre_generate: bool = false
var time_started: int

var grid_level: Grid

var cells_shown: int
var cells_left: int
var mines_left: int

var tile_hidden: int
var tile_revealed: int

var flag_hidden: int = -1
var flag_revealed: int
var flag_nodes: Dictionary = {}

func load_level() -> void:
	var level_info: LevelInfo = LevelManager.get_level()
	self.width = level_info.x
	self.height = level_info.y
	self.mines = level_info.mines
	self.pre_generate = level_info.pre_generate

func _ready() -> void:
	AudioManager.pause_audio_bus(AudioManager.MUSIC)

	load_level()
	grid_level = Grid.new(width, height, mines, pre_generate)
	_generate_3d_grid()
	$CharacterBody3D.position = Vector3(self.width, 1, self.height)

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
	level_ui.setup_ui(self.mines, self.mines_left, self.cells_left)

	time_started = Time.get_ticks_msec()

func _generate_3d_grid() -> void:
	tiles_grid_map.cell_scale *= 0.995
	tiles_collision.position = Vector3(self.width, 0, self.height)
	tiles_collision.shape.size = Vector3(self.width * 2, 2, self.height * 2)
	for x in range(self.width):
		for y in range(self.height):
			tiles_grid_map.set_cell_item(Vector3i(x, 0, y), self.tile_hidden, grid_level.rng.randi_range(0,23))

func _mine_grid(pos: Vector2i):
	var grid_pos: Vector2i = Vector2i(pos.x, pos.y)
	grid_level.mine(grid_pos, get_tree())

func _flag_grid(pos: Vector2i):
	var grid_pos: Vector2i = Vector2i(pos.x, pos.y)
	grid_level.flag(grid_pos)

func _flag_cell(pos: Vector2i, flag: bool):
	var flag_pos: Array = [0, 10, 16, 22]
	var grid_map_pos: Vector3i = Vector3i(pos.x, 0, pos.y)
 
	if flag:
		# CHANGED: Update mines_left UI immediately (before delay) so it feels responsive
		self.mines_left -= 1
		if self.mines_left >= 0:
			level_ui.mines_left_value(self.mines_left)
 
		# CHANGED: Delay flag appearance by 0.8s to sync with the wave animation
		await get_tree().create_timer(0.8).timeout
 
		# CHANGED: Spawn a real MeshInstance3D instead of setting a GridMap cell
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.mesh = flags_grid_map.mesh_library.get_item_mesh(self.flag_revealed)
		var local_pos := flags_grid_map.map_to_local(grid_map_pos)
		add_child(mesh_instance)
		mesh_instance.global_position = flags_grid_map.to_global(local_pos)
		mesh_instance.scale = Vector3.ZERO
 
		# CHANGED: Store the node so we can remove it when unflagging
		flag_nodes[pos] = mesh_instance
 
		# CHANGED: Tween scale from 0 to full size with elastic bounce feel
		var tween := create_tween()
		tween.tween_property(mesh_instance, "scale", Vector3.ONE, 1.5) \
			.set_trans(Tween.TRANS_ELASTIC) \
			.set_ease(Tween.EASE_OUT)
 
	else:
		# CHANGED: Remove the spawned MeshInstance3D instead of clearing a GridMap cell
		if pos in flag_nodes:
			flag_nodes[pos].queue_free()
			flag_nodes.erase(pos)
 
		self.mines_left += 1
		if self.mines_left >= 0:
			level_ui.mines_left_value(self.mines_left)

func _reveal_cell(pos: Vector2i):
	var grid_map_pos: Vector3i = Vector3i(pos.x, 0, pos.y)
	self.cells_shown += 1

	self.numbers_grid_map.set_cell_item(grid_map_pos, self.grid_level.grid[pos.x][pos.y].mines - 1, 12)
	self.tiles_grid_map.set_cell_item(grid_map_pos, self.tile_revealed, grid_level.rng.randi_range(0,23))

	level_ui.tiles_left_value(cells_left - cells_shown)
	
	if cells_shown == cells_left:
		var time: int = (Time.get_ticks_msec() - time_started) / 1000
		self._on_win(time)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_button"):
		self.pause_menu_state = not self.pause_menu_state

func _on_win(time :int) -> void:
	LevelManager.win(time)
	GameEvents.is_mouse_captured.emit(false)
	victory_label.visible = true
	await get_tree().create_timer(2.0).timeout
	_exit_game()

func _on_defeat() -> void:
	LevelManager.lose()
	GameEvents.is_mouse_captured.emit(false)
	defeat_label.visible = true
	await get_tree().create_timer(2.0).timeout
	_exit_game()

func _exit_game() -> void:
	if LevelManager.idx == -1:
		SceneManager.transition_deferred(SceneManager.SCENES.CUSTOM_LEVEL_MENU)
	else:
		SceneManager.transition_deferred(SceneManager.SCENES.LEVEL_MENU)

func _resume_game() -> void:
	self.pause_menu_state = false

func _update_pause_menu_state() -> void:
	if self.pause_menu_state:
		AudioManager.play_audio_bus(AudioManager.MUSIC)
		GameEvents.is_mouse_captured.emit(false)
		self.level_pause_menu.visible = true
	else:
		AudioManager.pause_audio_bus(AudioManager.MUSIC)
		GameEvents.is_mouse_captured.emit(true)
		self.level_pause_menu.visible = false
