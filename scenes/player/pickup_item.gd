extends Area2D

@export var inventory: InventoryComponent
@onready var just_dropped = $"..".just_dropped


func _ready() -> void:
	self.body_entered.connect(_on_pickup_area_body_entered)
	inventory.inventory_changed.connect(_on_inventory_changed)
	$"..".item_protection_expired.connect(_on_item_protection_expired)


func _on_pickup_area_body_entered(body: Node) -> void:
	if !is_multiplayer_authority():
		return

	# Only handle real pickup objects (adapt this to your game)
	if not body.is_in_group("world_pickup"):
		return

	# Do NOT pick up items we just dropped and are still protected
	if just_dropped.has(body):
		return

	# Assuming your pickup has an ItemData or similar
	var data: ItemData = body.item_data
	if inventory.add_item(data):
		body.queue_free()


func _on_inventory_changed():
	just_dropped = $"..".just_dropped


func _on_item_protection_expired():
	just_dropped = $"..".just_dropped
