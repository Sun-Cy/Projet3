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
func interact(actor: Node2D) -> void:
	# If there's an AnimationPlayer with a 'died' animation, play it
	# The 'died' animation contains a call to `queue_free` in the scene
	if has_node("AnimationPlayer"):
		var ap = $AnimationPlayer
		if ap.has_animation("died"):
			ap.play("died")
			return

	# Fallback: immediately remove the node
	queue_free()
