extends PanelContainer
@onready var bus_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/BusLabel
@onready var volume_slider: HSlider = $MarginContainer/VBoxContainer/VolumeSlider
@onready var volume_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Volume

var bus_name: String

func setup(name: String, volume: float) -> void:
	bus_label.text = name
	volume_slider.value = volume
	volume_label.text = "%d%%" % [int(volume * 100)]
	self.bus_name = name

func set_volume_label(volume: float):
	volume_label.text = "%d%%" % [int(volume * 100)]

func _on_volume_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume(self.bus_name, value)
	set_volume_label(value)
