# data/item_data.gd
class_name ItemData
extends Resource

@export var id: StringName              # e.g. &"rope"
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D

@export_group("Insanity")
@export var insanity_on_pickup: int = 0   # + or - when collected
@export var insanity_if_missing: int = 0  # applied when a check fails

@export_group("Meta")
@export var tags: Array[StringName] = []  # e.g. [&"tool", &"memory"]
