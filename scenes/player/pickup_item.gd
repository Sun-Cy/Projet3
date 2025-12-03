extends Area2D
class_name PickupArea   # optional, but nice

@export var inventory: InventoryComponent

@onready var player: Player = $".."
@onready var just_dropped: Dictionary = player.just_dropped


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(body: Node) -> void:
	#if !player.is_multiplayer_authority():
	#	return
	
	if not body.is_in_group("world_pickup"):
		return
	
	if just_dropped.has(body):
		return  # local drop-protection
	
	_request_pickup(body as WorldPickup)


func _request_pickup(pickup: WorldPickup) -> void:
	var pickup_path := pickup.get_path()
	player.rpc("rpc_pickup_item", pickup_path)
