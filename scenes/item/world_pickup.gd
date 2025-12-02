extends Area2D
class_name WorldPickup

@export var item_data: ItemData
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D


func build_network_state() -> Dictionary:
	return {
		"name": name,
		"scene": scene_file_path,
		"state": {
			"position": global_position,
		}
	}

func apply_network_state(state: Dictionary) -> void:
	global_position = state.position


func _ready() -> void:
	add_to_group("world_pickup")
	_update_visual()

func _update_visual() -> void:
	if sprite and item_data and item_data.icon:
		sprite.texture = item_data.icon
