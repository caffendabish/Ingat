# minigame/minigame.gd
extends Node

signal minigame_finished

@export var time_limit: float = 180.0
@export var scenes: Array[PackedScene]   # drag your 3 scenes here

@onready var container: Node = $SceneContainer
@onready var timer_label: Label = $HUD/TimerLabel

var time_left: float
var running := false
var current_scene: Node

func _ready() -> void:
	time_left = time_limit
	load_area(0)
	running = true

func _process(delta: float) -> void:
	if not running: return
	time_left -= delta
	timer_label.text = "%02d:%02d" % [int(time_left) / 60, int(time_left) % 60]
	if time_left <= 0.0:
		end_minigame()

func load_area(index: int) -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = scenes[index].instantiate()
	container.add_child(current_scene)

func end_minigame() -> void:
	running = false
	minigame_finished.emit()
