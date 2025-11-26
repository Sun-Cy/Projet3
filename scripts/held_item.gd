# res://items/held_item.gd
extends Node2D
class_name HeldItem

func get_user() -> Node:
	if get_parent() and get_parent().get_parent():
		return get_parent().get_parent()
	return null

## Called when LMB / "attack" is pressed
func use_primary() -> void:
	# Default: bare-hand punch or do nothing – overridden by tools/weapons
	pass

## Called when RMB / "use" is pressed
func use_secondary() -> void:
	# Default: maybe do nothing, or generic "interact" if you want
	pass

## Optional: called when equipped/unequipped, if item needs setup
func on_equipped() -> void:
	pass

func on_unequipped() -> void:
	pass
