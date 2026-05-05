extends Node

const GAME_SAVE_FILE = "user://game.sav"
const BEST_TIMES_FILE = "user://best_times.sav"

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	var game_save_file: FileAccess = FileAccess.open(GAME_SAVE_FILE, FileAccess.READ)
	if game_save_file:
		restore_levels(game_save_file)
		if not game_save_file.eof_reached():
			restore_audio(game_save_file)
		if not game_save_file.eof_reached():
			restore_window_mode(game_save_file)
		if not game_save_file.eof_reached():
			restore_pov(game_save_file)

	var best_times_file: FileAccess = FileAccess.open(BEST_TIMES_FILE, FileAccess.READ)
	if best_times_file:
		var best_times_buffer: PackedByteArray = best_times_file.get_buffer(best_times_file.get_length())
		var unpacked_best_times = bytes_to_var_with_objects(best_times_buffer)
		if unpacked_best_times:
			LevelManager.levels_time.assign(unpacked_best_times)
	LevelManager.levels_time.resize(LevelManager.completed_levels)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_handle_exit_save()

func _handle_exit_save():
	var game_save_file: FileAccess = FileAccess.open(GAME_SAVE_FILE, FileAccess.WRITE)
	if game_save_file:
		save_levels(game_save_file)
		save_audio(game_save_file)
		save_window_mode(game_save_file)
		save_pov(game_save_file)
		
	var best_times_file: FileAccess = FileAccess.open(BEST_TIMES_FILE, FileAccess.WRITE)
	var best_times_buffer: PackedByteArray = var_to_bytes_with_objects(LevelManager.levels_time)
	if best_times_file:
		best_times_file.store_buffer(best_times_buffer)
	get_tree().quit()

func restore_levels(save_file: FileAccess):
	LevelManager.completed_levels = save_file.get_64()

func save_levels(save_file: FileAccess):
	save_file.store_64(LevelManager.completed_levels)

func restore_audio(save_file: FileAccess):
	for i in range(AudioServer.bus_count):
		AudioServer.set_bus_volume_linear(i, save_file.get_float())

func save_audio(save_file: FileAccess):
	for i in range(AudioServer.bus_count):
		save_file.store_float(AudioServer.get_bus_volume_linear(i))

func restore_window_mode(save_file: FileAccess):
	var window_mode: int = save_file.get_64()
	DisplayServer.window_set_mode(window_mode)

func save_window_mode(save_file: FileAccess):
	save_file.store_64(DisplayServer.window_get_mode())

func restore_pov(save_file: FileAccess):
	var state: int = save_file.get_64()
	PlayerManager.current_state = state

func save_pov(save_file: FileAccess):
	save_file.store_64(PlayerManager.current_state)

func delete_save() -> void:
	var err = DirAccess.remove_absolute(GAME_SAVE_FILE)
	if err != OK:
		print("Error removing file: ", error_string(err))
	err = DirAccess.remove_absolute(BEST_TIMES_FILE)
	if err != OK:
		print("Error removing file: ", error_string(err))
	LevelManager.completed_levels = 0
	LevelManager.levels_time.clear()
