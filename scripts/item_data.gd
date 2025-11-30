extends Resource
class_name ItemData

@export var display_name: String
@export var icon: Texture2D
@export var is_stackable: bool

# Scene used when the item is in the player's hand.
@export var held_scene: PackedScene

# Scene used when the item is on the ground (pickup).
# You can reuse the same scene for all items if you prefer.
@export var world_pickup_scene: PackedScene
