extends Node

const SFX_POOL_SIZE := 12
const SETTINGS_PATH := "user://audio_settings.cfg"
const SILENT_DB := -80.0

# Add your own sounds here. Name -> file path.
const SFX_LIBRARY := {
"mumble": "res://Chapter One/Sound/819689__intramental__weather-radio-noaa-august-15-2025.ogg",
	"dialogue": "res://Chapter One/Sound/dialogue.wav",
	"step": "res://Chapter One/Sound/step.wav",
}
const MUSIC_LIBRARY := {
	"school": "res://Chapter One/Sound/829715__kevp888__250731_175435_ph_lively_afternoon_in_filipino_suburb.wav",
}
const AMBIENT_LIBRARY := {
	"school": "res://Chapter One/Sound/829715__kevp888__250731_175435_ph_lively_afternoon_in_filipino_suburb.wav",
	"classroom": "res://Chapter One/Sound/765192__janica_uys241180__classroom-ambience.wav",
	"neighbour": "res://Chapter One/Sound/423515__martinsadoux__inside-a-house-neighbourhood.wav",
	"tv_static": "res://Chapter One/Sound/TV_STATIC.mp3",
	"horror": "res://Chapter One/Sound/horr_ambience.wav",
	"nightly": "res://Chapter One/Sound/nightly.wav",
	"nightly2": "res://Chapter One/Sound/nightly2.wav",
	"thunder": "res://Chapter One/Sound/868579__bobvoldar__thunderclap-and-rumble-with-no-rain-9126.wav",
	"chatter": "res://Chapter One/Sound/chatter.wav",
	"chatter2": "res://Chapter One/Sound/chatter2.wav",
	"thunder1": "res://Chapter One/Sound/thunder1.wav",
	"thunder2": "res://Chapter One/Sound/thunder2.wav",
	"thunder3": "res://Chapter One/Sound/thunder3.wav",
	"cries": "res://Chapter One/Sound/cries.wav",
	"screams": "res://Chapter One/Sound/screams.mp3",
	"crowd": "res://Chapter One/Sound/CROWD.mp3",
	"ticktock": "res://Chapter One/Sound/ticktock.wav",
	
	}

var sfx_offset_db := 0.0

var _cache: Dictionary = {}
var _music_players: Array[AudioStreamPlayer] = []
var _active_music := 0
var _fade_tween: Tween
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx := 0
var _ambient_player: AudioStreamPlayer
var _ambient_tween: Tween
var _ambient_current := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for i in 2:
		var p := AudioStreamPlayer.new()
		p.bus = "Music"
		p.volume_db = SILENT_DB
		add_child(p)
		_music_players.append(p)

	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)

	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Music"
	_ambient_player.volume_db = SILENT_DB
	add_child(_ambient_player)
	# the imported ambience files don't loop, so restart them when they end
	_ambient_player.finished.connect(_on_ambient_finished)

	load_settings()


func _get_stream(path: String) -> AudioStream:
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path]


# ---------- Music ----------

func play_music(track: String, fade_time := 1.0, volume_db := 0.0) -> void:
	if track == "":
		stop_music(fade_time)
		return
	if not MUSIC_LIBRARY.has(track):
		push_warning("Unknown music: " + track)
		return

	var stream := _get_stream(MUSIC_LIBRARY[track])
	var current := _music_players[_active_music]

	# Same track already playing: don't restart, just change volume
	if current.stream == stream and current.playing:
		set_music_volume_db(volume_db, fade_time)
		return

	var next_index := 1 - _active_music
	var incoming := _music_players[next_index]
	incoming.stream = stream
	incoming.volume_db = SILENT_DB
	incoming.play()

	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween().set_parallel(true)
	_fade_tween.tween_property(incoming, "volume_db", volume_db, fade_time)
	_fade_tween.tween_property(current, "volume_db", SILENT_DB, fade_time)
	_fade_tween.chain().tween_callback(current.stop)

	_active_music = next_index


func set_music_volume_db(db: float, fade_time := 0.5) -> void:
	if _fade_tween:
		_fade_tween.kill()
	var current := _music_players[_active_music]
	_fade_tween = create_tween()
	_fade_tween.tween_property(current, "volume_db", db, fade_time)


func stop_music(fade_time := 1.0) -> void:
	if _fade_tween:
		_fade_tween.kill()
	var current := _music_players[_active_music]
	_fade_tween = create_tween()
	_fade_tween.tween_property(current, "volume_db", SILENT_DB, fade_time)
	_fade_tween.tween_callback(current.stop)


# ---------- Extra audio layer (ambient) ----------

func play_ambient(sound: String, volume_db := 0.0, fade_time := 1.0) -> void:
	if sound == "":
		stop_ambient(fade_time)
		return
	if not AMBIENT_LIBRARY.has(sound):
		push_warning("Unknown ambient: " + sound)
		return

	if _ambient_tween:
		_ambient_tween.kill()
	_ambient_tween = create_tween()

	if _ambient_current == sound and _ambient_player.playing:
		_ambient_tween.tween_property(_ambient_player, "volume_db", volume_db, fade_time)
		return

	_ambient_current = sound
	_ambient_player.stream = _get_stream(AMBIENT_LIBRARY[sound])
	_ambient_player.volume_db = SILENT_DB
	_ambient_player.play()
	_ambient_tween.tween_property(_ambient_player, "volume_db", volume_db, fade_time)


func stop_ambient(fade_time := 1.0) -> void:
	if _ambient_tween:
		_ambient_tween.kill()
	_ambient_current = ""
	_ambient_tween = create_tween()
	_ambient_tween.tween_property(_ambient_player, "volume_db", SILENT_DB, fade_time)
	_ambient_tween.tween_callback(_ambient_player.stop)


func _on_ambient_finished() -> void:
	if _ambient_current != "":
		_ambient_player.play()


# ---------- Extra layers (stack on top of ambient, loop on their own) ----------

var _layers: Dictionary = {}   # layer name -> {player, tween, sound}


func play_layer(layer: String, sound: String, volume_db := 0.0, fade_time := 1.0, bus := "Music") -> void:
	var path := ""
	if AMBIENT_LIBRARY.has(sound):
		path = AMBIENT_LIBRARY[sound]
	elif SFX_LIBRARY.has(sound):
		path = SFX_LIBRARY[sound]
	else:
		push_warning("Unknown layer sound: " + sound)
		return

	if not _layers.has(layer):
		var p := AudioStreamPlayer.new()
		p.volume_db = SILENT_DB
		p.finished.connect(_on_layer_finished.bind(layer))
		add_child(p)
		_layers[layer] = {"player": p, "tween": null, "sound": "", "target_db": SILENT_DB}

	var data: Dictionary = _layers[layer]
	var player: AudioStreamPlayer = data["player"]
	data["target_db"] = volume_db
	player.bus = bus
	if data["tween"]:
		data["tween"].kill()

	# Same sound already playing: just fade to the new volume
	if data["sound"] != sound or not player.playing:
		data["sound"] = sound
		player.stream = _get_stream(path)
		player.volume_db = SILENT_DB
		player.play()

	var tween := create_tween()
	data["tween"] = tween
	tween.tween_property(player, "volume_db", volume_db, fade_time)


func stop_layer(layer: String, fade_time := 1.0) -> void:
	if not _layers.has(layer):
		return
	var data: Dictionary = _layers[layer]
	var player: AudioStreamPlayer = data["player"]
	if data["tween"]:
		data["tween"].kill()
	data["sound"] = ""
	var tween := create_tween()
	data["tween"] = tween
	tween.tween_property(player, "volume_db", SILENT_DB, fade_time)
	tween.tween_callback(player.stop)


func stop_all_layers(fade_time := 1.0) -> void:
	for layer in _layers:
		stop_layer(layer, fade_time)


# Make every playing layer whose name starts with `prefix` louder/quieter by `delta_db`
# (negative = quieter), e.g. shift_layers_db("storm_thunder", -4.0, 3.0)
func shift_layers_db(prefix: String, delta_db: float, fade_time := 2.0) -> void:
	for layer in _layers:
		if not String(layer).begins_with(prefix):
			continue
		var data: Dictionary = _layers[layer]
		var player: AudioStreamPlayer = data["player"]
		if data["sound"] == "" or not player.playing:
			continue
		if data["tween"]:
			data["tween"].kill()
		data["target_db"] = data["target_db"] + delta_db
		var tween := create_tween()
		data["tween"] = tween
		tween.tween_property(player, "volume_db", data["target_db"], fade_time)


func _on_layer_finished(layer: String) -> void:
	var data: Dictionary = _layers[layer]
	if data["sound"] != "":
		(data["player"] as AudioStreamPlayer).play()


# ---------- Sound effects ----------

func play_sfx(sound: String, pitch_variation := 0.0, volume_db := 0.0) -> void:
	if not SFX_LIBRARY.has(sound):
		push_warning("Unknown SFX: " + sound)
		return

	var player := _find_free_sfx_player()
	player.stream = _get_stream(SFX_LIBRARY[sound])
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.volume_db = volume_db + sfx_offset_db
	player.play()


func _find_free_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing:
			return p
	var stolen := _sfx_players[_next_sfx]
	_next_sfx = (_next_sfx + 1) % _sfx_players.size()
	return stolen


func play_sfx_2d(sound: String, position: Vector2, pitch_variation := 0.0, volume_db := 0.0) -> void:
	if not SFX_LIBRARY.has(sound):
		return
	var p := AudioStreamPlayer2D.new()
	p.stream = _get_stream(SFX_LIBRARY[sound])
	p.bus = "SFX"
	p.volume_db = volume_db + sfx_offset_db
	p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	get_tree().current_scene.add_child(p)
	p.global_position = position
	p.finished.connect(p.queue_free)
	p.play()


# ---------- Player volume settings (sliders) ----------

func set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))
	AudioServer.set_bus_mute(idx, linear <= 0.001)


func get_bus_volume(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	return db_to_linear(AudioServer.get_bus_volume_db(idx))


func save_settings() -> void:
	var cfg := ConfigFile.new()
	for bus in ["Master", "Music", "SFX"]:
		cfg.set_value("volume", bus, get_bus_volume(bus))
	cfg.save(SETTINGS_PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	for bus in ["Master", "Music", "SFX"]:
		set_bus_volume(bus, cfg.get_value("volume", bus, 1.0))
