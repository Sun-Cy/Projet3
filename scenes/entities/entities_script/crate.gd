extends Node2D

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


# Called by the interaction component when a player presses the interact key
func interact(_actor: Node2D) -> void:
	var health_comp: HealthComponent = $HealthComponent
	if health_comp:
		health_comp.kill()
