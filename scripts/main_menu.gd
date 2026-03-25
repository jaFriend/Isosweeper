extends Control


func _on_levels_button_pressed() -> void:
	SceneManager.transition(SceneManager.SCENES.LEVEL_MENU)

func _on_custom_level_button_pressed() -> void:
	SceneManager.transition(SceneManager.SCENES.CUSTOM_LEVEL_MENU)

func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_settings_button_pressed() -> void:
	SceneManager.transition(SceneManager.SCENES.SETTINGS)
