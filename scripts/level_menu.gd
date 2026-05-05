extends Control

var cards: Array
@export var card_scene: PackedScene = preload("res://scenes/level_card.tscn")
@onready var container: VBoxContainer = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var scroll_container: ScrollContainer = $PanelContainer/MarginContainer/ScrollContainer

func _ready() -> void:
	AudioManager.play_audio_bus(AudioManager.MUSIC)
	GameEvents.mouse_captured_state(false)
	if LevelManager.levels.size() == 0:
		return
	
	var status: bool = true
	status = await render_levels()
	
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
		card.selected.connect(_set_scroll_pos)
	await get_tree().process_frame
	scroll_container.scroll_vertical = LevelManager.menu_scroll_pos
	return true


func _on_back_button_pressed() -> void:
	_set_scroll_pos(0)
	SceneManager.transition(SceneManager.SCENES.MAIN_MENU)

func _set_scroll_pos(_idx: int):
	LevelManager.save_scroll_pos(scroll_container.scroll_vertical)
