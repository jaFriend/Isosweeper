extends Node

enum TileState { HIDDEN, REVEALED, EXPLODED, FLAGGED }
var state: TileState = TileState.HIDDEN:
	set(value):
		state = value
		_update_visual()

@onready var block: Node = get_node("Block")
@onready var block_revealed: Node = get_node("Block_revealed")
@onready var block_flagged: Node = get_node("Block_flagged")

var grid_coords: Vector2i

func setup(coords: Vector2i):
	grid_coords = coords

func get_tile_coordinates() -> Vector2i:
	return grid_coords

func _update_visual() -> void:
	match state:
		TileState.REVEALED:
			self.block_revealed.visible = true
			self.block.visible = false

		TileState.FLAGGED:
			self.block_flagged.visible = true
			self.block.visible = false
		TileState.HIDDEN:
			self.block.visible = true
			self.block_flagged.visible = false

func _flag(flag: bool) -> void:
	if flag:
		self.state = TileState.FLAGGED
	else:
		self.state = TileState.HIDDEN
		
func _reveal() -> void:
	self.state = TileState.REVEALED
