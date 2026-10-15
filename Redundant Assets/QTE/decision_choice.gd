# data/decision_choice.gd
class_name DecisionChoice
extends Resource

@export var label: String                 # "Attic" / "Window"
@export var required_item: StringName     # &"rope" or &"" for none
@export var scene_with_item: PackedScene  # or a cutscene/dialogue ID
@export var scene_without_item: PackedScene
@export var insanity_without_item: int = 5  # extra penalty if missing
@export var insanity_with_item: int = 0
