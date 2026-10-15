class_name Debris
extends Area2D

signal touched_player(debris: Debris)

var velocity := Vector2(0, 300)
var spin := 0.0
var kill_rect := Rect2(-300, -400, 2520, 1900)   # deleted when it leaves this area


func _ready() -> void:
	body_entered.connect(func(_body): touched_player.emit(self))


func _physics_process(delta: float) -> void:
	position += velocity * delta
	rotation += spin * delta
	if not kill_rect.has_point(position):
		queue_free()
