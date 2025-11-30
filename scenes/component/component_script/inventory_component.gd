extends Node2D
class_name InventoryComponent

@export_range(1,50,1)
var slot_count: int = 10:
	set(value):
		slot_count = max(1, value)
		_resize_slots()

var slots: Array[ItemData] = []

signal inventory_changed()

func _ready() -> void:
	if slots.is_empty():
		_resize_slots()


func _resize_slots() -> void:
	var old := slots.duplicate()
	slots.resize(slot_count)
	
	for i in slot_count:
		if i < old.size():
			slots[i] = old[i]
		else:
			slots[i] = null
	inventory_changed.emit()


func get_slot(i: int) -> ItemData:
	if i < 0 or i >= slot_count:
		return null
	return slots[i]


func set_slot(i: int, data: ItemData) -> void:
	if i < 0 or i >= slot_count:
		return
	slots[i] = data
	inventory_changed.emit()


func add_item(data: ItemData) -> bool:
	for i in slot_count:
		if slots[i] == null:
			slots[i] = data
			inventory_changed.emit()
			return true
	return false # inventory is full


func removed_item(i: int) -> ItemData:
	if i < 0 or i >= slot_count:
		return
	var data: ItemData = slots[i]
	slots[i] = null
	inventory_changed.emit()
	return data


func find_first(data: ItemData) -> int:
	for i in slot_count:
		if slots[i] == data:
			return i
	return -1
