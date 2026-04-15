extends Node

@onready var character_scene_3d: PackedScene = preload("res://scenes/character_body_3d.tscn")
@onready var character_scene: PackedScene = preload("res://scenes/proto_controller.tscn")

enum POV_STATES {
	FIRST_PERSON,
	THIRD_PERSON
}

var current_state: POV_STATES = POV_STATES.THIRD_PERSON

func create_character() -> Node:
	match current_state:
		POV_STATES.THIRD_PERSON:
			return _create_3d_character()
		_:
			return _create_character()

func _create_3d_character() -> Node:
	var character = character_scene_3d.instantiate()
	character.scale = Vector3(0.5,0.5,0.5)
	return character

func _create_character() -> Node:
	var character = character_scene.instantiate()
	return character
	
