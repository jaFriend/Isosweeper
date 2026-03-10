extends Control

@onready var grid_x_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/GridXLine
@onready var grid_y_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/GridYLine
@onready var grid_mines_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MinesLine
@onready var pre_generate_check: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/PreGenerateCheck
@onready var invalid_input: Label = $PanelContainer/MarginContainer/VBoxContainer/InvalidInput

func _on_play_button_pressed() -> void:
	var x: int = grid_x_input.text.to_int()
	var y: int = grid_y_input.text.to_int()
	var mines: int = grid_mines_input.text.to_int()
	var pre_generate: bool = pre_generate_check.button_pressed
	if x <= 0 or y <= 0 or mines <= 0:
		invalid_input.visible = true
		return
	elif x * y <= mines:
		invalid_input.visible = true
		return

	var level_info: LevelInfo = LevelInfo.new()
	level_info.x = x
	level_info.y = y
	level_info.mines = mines
	level_info.pre_generate = pre_generate
	LevelManager.load_custom_level(level_info)
	
func _on_back_button_pressed() -> void:
	SceneManager.transition("res://scenes/main_menu.tscn")
