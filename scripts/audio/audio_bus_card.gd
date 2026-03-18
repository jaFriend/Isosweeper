extends PanelContainer
@onready var bus_label: Label = $MarginContainer/VBoxContainer/BusLabel
@onready var volume_slider: HSlider = $MarginContainer/VBoxContainer/VolumeSlider

var bus_name: String

func setup(name: String, volume: float) -> void:
	bus_label.text = name
	volume_slider.value = volume
	self.bus_name = name

func _on_volume_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume(self.bus_name, value)
