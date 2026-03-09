extends Control

var levels: Array[LevelInfo]
var cards: Array
@export var card_scene: PackedScene = preload("res://scenes/level_card.tscn")
@onready var container: VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer

func _ready() -> void:
	var status: bool
	status = open_levels()
	if not status:
		return
	
	var unlocked_levels: int = 10
	status = render_levels(unlocked_levels)
	
	if not status:
		return
	



func open_levels() -> bool:
	var filename: String = "res://levels.dat"
	var file: FileAccess = FileAccess.open(filename, FileAccess.READ)
	var loaded_bytes: PackedByteArray
	if file:
		loaded_bytes = file.get_buffer(file.get_length())
	else:
		return false
		
	var unpacked_data = bytes_to_var_with_objects(loaded_bytes)
	
	levels.assign(unpacked_data)
	return true

func render_levels(unlocked_levels: int) -> bool:
	for child in container.get_children():
		child.queue_free()
	
	for i in range(levels.size()):
		var card = card_scene.instantiate()
		container.add_child(card)
		cards.append(card)
		card.setup(i, levels[i])
		if i < unlocked_levels:
			card._unlock()
		card.selected.connect(_load_level)
	
	return true

func _load_level(idx: int):
	print(idx)
