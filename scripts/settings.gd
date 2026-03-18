extends Control

@onready var container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2
@export var audio_bus_card: PackedScene = preload("res://scenes/audio/audio_bus_card.tscn")

func _ready() -> void:
	render_audio_bus_options()

func render_audio_bus_options() -> void:
	for i in range(AudioServer.bus_count):
		var card = audio_bus_card.instantiate()
		container.add_child(card)
		card.setup(AudioServer.get_bus_name(i), AudioServer.get_bus_volume_linear(i))



func _on_back_button_pressed() -> void:
	SceneManager.transition(SceneManager.SCENES.MAIN_MENU)


func _on_delete_data_button_pressed() -> void:
	SaveManager.delete_save()
