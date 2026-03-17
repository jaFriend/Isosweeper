extends Node

const MAIN_MUSIC: StringName = &"main_music"
const CLICK_SOUND: StringName = &"click_sound"

class AudioTrack:
	var stream: AudioStream
	var volume: float
	var bus: String
	
	func _init(init_stream: AudioStream, init_volume: float, init_bus: StringName = "Master") -> void:
		self.stream = init_stream
		self.volume = init_volume
		self.bus = init_bus

class StreamPlayer:
	var player: AudioStreamPlayer
	var is_disposable: bool
	signal destroyed(instance)
	func _init(parent: Node, bus: StringName, disposable: bool = false) -> void:
		self.is_disposable = disposable
		self.player = AudioStreamPlayer.new()
		parent.add_child(self.player)
		self.player.bus = bus
		self.player.process_mode = parent.PROCESS_MODE_ALWAYS
		if is_disposable:
			self.player.finished.connect(_on_finished)
	func _on_finished() -> void:
		destroyed.emit(self)
		self.player.queue_free()

	func play_track(audio_track: AudioTrack):
		self.player.stream = audio_track.stream
		self.player.volume_db = linear_to_db(audio_track.volume)
		
		self.player.play()
	func stop():
		self.player.stop()

class StreamPlayers:
	var buses: Dictionary
	
	class BusController:
		var players: Array[StreamPlayer]
		var single: bool
		
		func _init(parent: Node, name: StringName, is_single: bool) -> void:
			self.single = is_single
			if is_single:
				self.players.append(StreamPlayer.new(parent, name))
		
		func play_track(parent: Node, audio_track: AudioTrack):
			if self.single:
				self.players[0].play_track(audio_track)
			else:
				var stream_player: StreamPlayer = StreamPlayer.new(parent, audio_track.bus, true)
				self.players.append(stream_player)
				stream_player.destroyed.connect(_on_player_destroyed)
				stream_player.play_track(audio_track)
		func stop() -> void:
			if single:
				self.players[0].stop()
		func _on_player_destroyed(instance):
			self.players.erase(instance)
	
	func _init() -> void:
		self.buses = {}
	
	func add_bus(parent: Node, bus_name: String, is_single: bool):
		self.buses[bus_name] = BusController.new(parent, bus_name, is_single)
	
	func play_audio_track(parent: Node, audio_track: AudioTrack):
		if self.buses.has(audio_track.bus):
			self.buses[audio_track.bus].play_track(parent, audio_track)
	func stop_player(bus: String):
		if bus in self.buses:
			self.buses[bus].stop()

var audio_tracks: Dictionary
var stream_players: StreamPlayers

const MUSIC: StringName = &"Music"
const EFFECTS: StringName = &"Effects"

func _ready() -> void:
	setup_players()
	setup_tracks()
	
	play_audio_track(self.MAIN_MUSIC)

func setup_players() -> void:
	stream_players = StreamPlayers.new()
	stream_players.add_bus(self, self.MUSIC, true)
	stream_players.add_bus(self, self.EFFECTS, false)

func setup_tracks() -> void:
	audio_tracks[self.MAIN_MUSIC] = AudioTrack.new(load("res://assets/audio/wealthy3.mp3"), 1.0, self.MUSIC)
	audio_tracks[self.CLICK_SOUND] = AudioTrack.new(load("res://assets/audio/click.mp3"), 1.0, self.EFFECTS)

func play_audio_track(name: StringName) -> void:
	if audio_tracks.has(name):
		stream_players.play_audio_track(self, audio_tracks[name])

func stop_audio_bus(name: StringName) -> void:
	stream_players.stop_player(name)
