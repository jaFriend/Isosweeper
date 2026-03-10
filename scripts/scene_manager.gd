extends Node

func transition(filename: String) -> void:
	get_tree().change_scene_to_file(filename)
