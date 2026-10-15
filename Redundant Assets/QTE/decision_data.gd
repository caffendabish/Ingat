# data/decision_data.gd
class_name DecisionData
extends Resource

@export var prompt: String
@export var choices: Array[DecisionChoice]
@export var time_limit: float = 6.0
@export var default_choice_index: int = 0   # if the player freezes
@export var timeout_insanity: int = 10      # hesitation penalty
