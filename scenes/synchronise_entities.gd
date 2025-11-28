extends Node2D

@onready var health: HealthComponent = $HealthComponent

func build_network_state() -> Dictionary:
	return {
		"name": name,
		"scene": scene_file_path,
		"state": {
			"position": global_position,
			"hp": health.health,
			# ... other component data
		}
	}

func apply_network_state(state: Dictionary) -> void:
	global_position = state.position
	health.health = state.hp
