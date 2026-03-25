extends Node

const BLANK_SCREEN: PackedScene = preload("res://scenes/blank_panel.tscn")
var _blank_instance: Control

const SCENES: Dictionary = {
	"MAIN_MENU": "res://scenes/main_menu.tscn",
	"LEVEL_MENU": "res://scenes/level_menu.tscn",
	"CUSTOM_LEVEL_MENU": "res://scenes/custom_level.tscn",
	"LEVEL": "res://scenes/level.tscn",
	"SETTINGS": "res://scenes/settings.tscn"
}

func _ready() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 128
	add_child(canvas)
	_blank_instance = BLANK_SCREEN.instantiate()
	_blank_instance.visible = false
	canvas.add_child(_blank_instance)

func transition(filename: String) -> void:
	get_tree().change_scene_to_file(filename)
	await get_tree().process_frame
	_blank_instance.visible = false

func transition_deferred(filename: String) -> void:
	_blank_instance.visible = true
	self.call_deferred("transition", filename)
