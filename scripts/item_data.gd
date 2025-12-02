extends Resource
class_name ItemData

@export var display_name: String
@export var icon: Texture2D
@export var is_stackable: bool = false

# Scene put in the player's ItemPivot when equipped.
@export var held_scene: PackedScene

# Scene used when the item is on the ground.
# In the refactor this will generally be the generic WorldPickup.tscn.
@export var world_pickup_scene: PackedScene = preload("res://scenes/item/world_pickup.tscn")
