extends Node2D

@export var tree_scene: PackedScene
@export var trees_to_spawn: int = 50

@export var area_min: Vector2 = Vector2(0, 0)
@export var area_max: Vector2 = Vector2(900, 600)

@onready var entities_root: Node2D = $Entities


func _ready() -> void:
	# Only the server decides where trees go
	if not multiplayer.is_server():
		return

	_spawn_trees()


func _spawn_trees() -> void:
	if tree_scene == null:
		push_warning("tree_scene is not assigned.")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	# Optional: use a fixed seed if you want deterministic generation
	# rng.seed = 123456789

	for i in trees_to_spawn:
		var tree := tree_scene.instantiate()

		# Set the position BEFORE adding it as a child
		tree.position = Vector2(
			rng.randf_range(area_min.x, area_max.x),
			rng.randf_range(area_min.y, area_max.y)
		)

		# 'true' ensures a unique network-safe name
		entities_root.add_child(tree, true)
