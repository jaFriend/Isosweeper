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
	var player: Node
	var is_disposable: bool
	var type: String # Must be either "Global" or "3D"
	
	signal destroyed(instance)
	func _init(parent: Node, bus: StringName, init_type: String = "Global", disposable: bool = false, pos: Vector3 = Vector3(0,0,0)) -> void:
		self.is_disposable = disposable
		match init_type:
			"3D":
				self.player = AudioStreamPlayer3D.new()
				self.type = init_type
			_:
				self.player = AudioStreamPlayer.new()
				self.type = init_type
		
		parent.add_child(self.player)
		self.player.bus = bus
		self.player.process_mode = parent.PROCESS_MODE_ALWAYS
		if is_disposable:
			self.player.finished.connect(_on_finished)
	func _on_finished() -> void:
		destroyed.emit(self)
		self.player.queue_free()

	func play_track(audio_track: AudioTrack):
		if self.player.stream == audio_track.stream and self.player.playing:
			return
		if self.player.stream != audio_track.stream:
			self.player.stream = audio_track.stream
			self.player.volume_db = linear_to_db(audio_track.volume)
		self.player.play()
	func stop() -> void:
		self.player.stop()
	func pause() -> void:
		self.player.stream_paused = true
	func play() -> void:
		self.player.stream_paused = false

class StreamPlayers:
	var buses: Dictionary
	
	class BusController:
		var players: Array[StreamPlayer]
		var single: bool
		
		func _init(parent: Node, name: StringName, is_single: bool) -> void:
			self.single = is_single
			if is_single:
				self.players.append(StreamPlayer.new(parent, name))
		
		func play_track(parent: Node, audio_track: AudioTrack) -> void:
			if self.single:
				self.players[0].play_track(audio_track)
			else:
				var stream_player: StreamPlayer = StreamPlayer.new(parent, audio_track.bus, "Global", true)
				self.players.append(stream_player)
				stream_player.destroyed.connect(_on_player_destroyed)
				stream_player.play_track(audio_track)
		func play_track_3d(parent: Node, audio_track: AudioTrack, pos: Vector3):
			if self.single:
				self.players[0].play_track(audio_track)
			else:
				var stream_player: StreamPlayer = StreamPlayer.new(parent, audio_track.bus, "3D", true, pos)
				stream_player.player.global_position = pos
				self.players.append(stream_player)
				stream_player.destroyed.connect(_on_player_destroyed)
				stream_player.play_track(audio_track)
		
		func stop() -> void:
			if single:
				self.players[0].stop()
			else:
				for player in self.players:
					player.stop()
		func pause() -> void:
			if single:
				self.players[0].pause()
			else:
				for player in self.players:
					player.pause()
		func play() -> void:
			if single:
				self.players[0].play()
			else:
				for player in self.players:
					player.play()
		func _on_player_destroyed(instance) -> void:
			self.players.erase(instance)
	
	func _init() -> void:
		self.buses = {}
	
	func add_bus(parent: Node, bus_name: String, is_single: bool) -> void:
		self.buses[bus_name] = BusController.new(parent, bus_name, is_single)
	
	func play_audio_track(parent: Node, audio_track: AudioTrack) -> void:
		if self.buses.has(audio_track.bus):
			self.buses[audio_track.bus].play_track(parent, audio_track)
	
	func stop_player(bus: StringName) -> void:
		if bus in self.buses:
			self.buses[bus].stop()
	
	func pause_player(bus: StringName) -> void:
		if self.buses.has(bus):
			self.buses[bus].pause()
	
	func play_player(bus: StringName) -> void:
		if self.buses.has(bus):
			self.buses[bus].play()

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
	audio_tracks[self.MAIN_MUSIC] = AudioTrack.new(load("res://assets/audio/wealthy3.mp3"), 0.5, self.MUSIC)
	audio_tracks[self.CLICK_SOUND] = AudioTrack.new(load("res://assets/audio/click.mp3"), 1.0, self.EFFECTS)

func play_audio_track(name: StringName) -> void:
	if audio_tracks.has(name):
		stream_players.play_audio_track(self, audio_tracks[name])

func stop_audio_bus(name: StringName) -> void:
	stream_players.stop_player(name)

func pause_audio_bus(name: StringName) -> void:
	stream_players.pause_player(name)

func play_audio_bus(name: StringName) -> void:
	stream_players.play_player(name)

func play_3d_sfx(bus_name: StringName, track_name: StringName, position: Vector3):
	if not stream_players.buses.has(bus_name) or not audio_tracks.has(track_name): 
		return
	stream_players.buses[bus_name].play_track_3d(self, audio_tracks[track_name], position)

func set_bus_volume(bus_name: StringName, percentage: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_volume_linear(bus_index, percentage)
