extends Node

const FILENAME = "user://game.sav"

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	var file: FileAccess = FileAccess.open(FILENAME, FileAccess.READ)
	if file:
		LevelManager.completed_levels = file.get_64()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_handle_exit_save()

func _handle_exit_save():
	var file: FileAccess = FileAccess.open(FILENAME, FileAccess.WRITE)
	if file:
		LevelManager.completed_levels = file.store_64(LevelManager.completed_levels)
	get_tree().quit()

func delete_save() -> void:
	DirAccess.remove_absolute(FILENAME)
