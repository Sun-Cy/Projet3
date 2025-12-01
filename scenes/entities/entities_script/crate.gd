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
	# Request destruction across the network so all peers remove this crate
	if has_node("AnimationPlayer"):
		var ap = $AnimationPlayer
		if ap.has_animation("died"):
			rpc("rpc_play_died")
			return

	# Fallback: request a networked free
	rpc("rpc_queue_free")


@rpc
func rpc_play_died() -> void:
	if has_node("AnimationPlayer"):
		var ap = $AnimationPlayer
		if ap.has_animation("died"):
			ap.play("died")
			return
	queue_free()


@rpc
func rpc_queue_free() -> void:
	queue_free()
