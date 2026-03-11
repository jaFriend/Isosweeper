extends PanelContainer

@onready var level_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Level
@onready var grid_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Grid
@onready var safety_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/Safety
@onready var mines_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/Mines
@onready var play_button: Button = $MarginContainer/VBoxContainer/Button
var index: int = 0
signal selected(idx: int)

func setup(level: int, level_info: LevelInfo):
	self.index = level
	play_button.disabled = true
	level_label.text = "Level: %d" % [level + 1]
	grid_label.text = "Grid: %dx%d" % [level_info.x, level_info.y]
	var safety_string: String = "Safety: "
	if not level_info.pre_generate:
		safety_string += "Yay"
	else:
		safety_string += "Nay"
	safety_label.text = safety_string

	mines_label.text = "Mines: %d" % [level_info.mines]

func _unlock() -> void:
	play_button.disabled = false

func _on_button_pressed() -> void:
	selected.emit(self.index)
