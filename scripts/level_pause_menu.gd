extends Control

signal exit_pressed
signal resume_pressed

func _on_exit_button_pressed() -> void:
	exit_pressed.emit()


func _on_resume_button_pressed() -> void:
	resume_pressed.emit()
