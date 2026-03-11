extends Control

var cards: Array
@export var card_scene: PackedScene = preload("res://scenes/level_card.tscn")
@onready var container: VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if LevelManager.levels.size() == 0:
		return
	
	var status: bool = true
	status = render_levels()
	
	if not status:
		return

func render_levels() -> bool:
	for child in container.get_children():
		child.queue_free()

	for i in range(LevelManager.levels.size()):
		var card = card_scene.instantiate()
		container.add_child(card)
		cards.append(card)
		card.setup(i, LevelManager.levels[i])
		if i < LevelManager.completed_levels + 1:
			card._unlock()
		if i < LevelManager.completed_levels:
			card.set_time(LevelManager.levels_time[i])
		card.selected.connect(LevelManager.load_level)

	return true


func _on_back_button_pressed() -> void:
	SceneManager.transition("res://scenes/main_menu.tscn")
