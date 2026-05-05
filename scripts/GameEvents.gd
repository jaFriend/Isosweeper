extends Node
 
signal player_send_mine_signal(vec: Vector2i)
signal player_send_flag_signal(vec: Vector2i)
var mouse_captured: bool = false

func mouse_captured_state(captured: bool) -> void:
	if captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.mouse_captured = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		self.mouse_captured = false
