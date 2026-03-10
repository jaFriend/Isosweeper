extends Control


func _on_levels_button_pressed() -> void:
	SceneManager.transition("res://scenes/level_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
