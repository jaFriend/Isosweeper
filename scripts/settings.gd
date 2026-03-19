extends Control

@onready var container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2
@onready var windowed_mode_button: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer3/WindowedModeOptionButton
@export var audio_bus_card: PackedScene = preload("res://scenes/audio/audio_bus_card.tscn")

func _ready() -> void:
	render_audio_bus_options()

func render_audio_bus_options() -> void:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_WINDOWED:
			windowed_mode_button.select(0)
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			windowed_mode_button.select(1)
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			windowed_mode_button.select(2)
	for i in range(AudioServer.bus_count):
		var card = audio_bus_card.instantiate()
		container.add_child(card)
		card.setup(AudioServer.get_bus_name(i), AudioServer.get_bus_volume_linear(i))



func _on_back_button_pressed() -> void:
	SceneManager.transition(SceneManager.SCENES.MAIN_MENU)


func _on_delete_data_button_pressed() -> void:
	SaveManager.delete_save()

func _on_windowed_mode_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
