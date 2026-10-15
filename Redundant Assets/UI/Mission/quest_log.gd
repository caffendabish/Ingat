extends Node

signal quest_added(id: StringName)
signal quest_updated(id: StringName)
signal quest_completed(id: StringName)

# id -> { "title": String, "description": String, "objectives": Array, "completed": bool }
# each objective -> { "text": String, "done": bool }
var quests: Dictionary = {}


func add_quest(id: StringName, title: String, description: String = "", objectives: Array = []) -> void:
	if quests.has(id):
		return   # never add the same quest twice
	var objs: Array = []
	for text in objectives:
		objs.append({"text": text, "done": false})
	quests[id] = {
		"title": title,
		"description": description,
		"objectives": objs,
		"completed": false,
	}
	quest_added.emit(id)


# Reveal a new objective on an existing quest
func add_objective(id: StringName, text: String) -> void:
	if not quests.has(id) or quests[id].completed:
		return
	quests[id].objectives.append({"text": text, "done": false})
	quest_updated.emit(id)


# Tick off an objective. The first objective is index 0.
func complete_objective(id: StringName, index: int) -> void:
	if not quests.has(id) or quests[id].completed:
		return
	var objs: Array = quests[id].objectives
	if index < 0 or index >= objs.size() or objs[index].done:
		return
	objs[index].done = true
	if objs.all(func(o): return o.done):
		complete_quest(id)
	else:
		quest_updated.emit(id)


func complete_quest(id: StringName) -> void:
	if not quests.has(id) or quests[id].completed:
		return
	quests[id].completed = true
	quest_completed.emit(id)


func has_quest(id: StringName) -> bool:
	return quests.has(id)


func is_completed(id: StringName) -> bool:
	return quests.has(id) and quests[id].completed


func is_objective_done(id: StringName, index: int) -> bool:
	return quests.has(id) and index < quests[id].objectives.size() \
			and quests[id].objectives[index].done


# Call at the start of a new game
func clear() -> void:
	quests.clear()
