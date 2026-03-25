extends Control

@onready var mines_label: Label = $PanelContainer/MarginContainer/HBoxContainer/Mines
@onready var mines_left_label: Label = $PanelContainer/MarginContainer/HBoxContainer/MinesLeft
@onready var tiles_left_label: Label = $PanelContainer/MarginContainer/HBoxContainer/TilesLeft

func setup_ui(mines: int, mines_left: int, tiles_left: int) -> void:
	self.tiles_left_label.text = str(tiles_left)
	self.mines_label.text = str(mines)
	self.mines_left_label.text = str(mines_left)

func mines_value(num: int) -> void:
	self.mines_label.text = str(num)
func mines_left_value(num: int) -> void:
	self.mines_left_label.text = str(num)
func tiles_left_value(num: int) -> void:
	self.tiles_left_label.text = str(num)
