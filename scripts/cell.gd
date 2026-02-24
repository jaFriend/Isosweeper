class_name Cell
extends RefCounted

var mines: int
var is_revealed: bool
var is_flagged: bool

const MINE = 9

func _init():
	self.mines = 0
	self.is_revealed = false
	self.is_flagged = false

func clear() -> void:
	_init()

func increase_mines() -> void:
	self.mines += 1

func set_as_mine() -> void:
	self.mines = self.MINE

func is_mine() -> bool:
	return self.mines == self.MINE

func mine() -> void:
	self.is_revealed = true
	
func mined() -> bool:
	return self.is_revealed

func flagged() -> bool:
	return self.is_flagged

func toggle_flagged() -> void:
	self.is_flagged = !self.is_flagged
