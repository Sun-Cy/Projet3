extends Node2D

@onready var entities_root: Node2D = self
@onready var players_root: Node2D = $Players


func _ready() -> void:
	# Only the server sends snapshots.
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(peer_id: int) -> void:
	var snapshot: Array = []
	
	for entity in entities_root.get_children():
		# Never include the Players container itself in the snapshot.
		if entity == players_root:
			continue
		
		if entity.has_method("build_network_state"):
			snapshot.append(entity.build_network_state())
	
	# Send only to the new player
	_rpc_receive_entities_snapshot.rpc_id(peer_id, snapshot)


@rpc("any_peer")
func _rpc_receive_entities_snapshot(snapshot: Array) -> void:
	# Safety: this RPC should only be processed on clients.
	if multiplayer.is_server():
		return
	
	# Collect existing non-player entities by name.
	var existing: Dictionary = {}  # name -> Node2D
	for child in entities_root.get_children():
		if child == players_root:
			continue
		existing[child.name] = child
	
	# Apply snapshot: update if exists, otherwise create.
	var seen: Dictionary = {}  # names that appear in the snapshot
	
	for data in snapshot:
		var name: String = data["name"]
		var scene_path: String = data["scene"]
		var state: Dictionary = data["state"]
		
		seen[name] = true
		
		var node: Node2D = null
		
		if existing.has(name):
			# Reuse existing node.
			node = existing[name]
		else:
			# Create new entity if it doesn't exist yet on this client.
			var packed: PackedScene = load(scene_path)
			node = packed.instantiate()
			node.name = name
			entities_root.add_child(node)
			
		if node.has_method("apply_network_state"):
			node.apply_network_state(state)
	
	# Remove ghosts: entities that exist locally but are not in the snapshot.
	for name in existing.keys():
		# If the server didn’t send this name, this is a ghost → delete it.
		if name == "ItemSpawner":
			continue
		if not seen.has(name):
			var ghost: Node2D = existing[name]
			ghost.queue_free()
