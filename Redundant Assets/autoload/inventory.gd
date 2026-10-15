# autoload/inventory.gd
extends Node

signal item_added(item: ItemData)
signal inventory_full

const MAX_ITEMS := 10
var items: Array[ItemData] = []

func add_item(item: ItemData) -> bool:
	if items.size() >= MAX_ITEMS:
		inventory_full.emit()
		return false
	items.append(item)
	if item.insanity_on_pickup != 0:
		GameState.add_insanity(item.insanity_on_pickup, "picked up " + item.id)
	item_added.emit(item)
	return true

func has_item(id: StringName) -> bool:
	return items.any(func(i): return i.id == id)

func get_item(id: StringName) -> ItemData:
	for i in items:
		if i.id == id:
			return i
	return null
