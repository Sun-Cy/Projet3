extends CharacterBody2D
class_name Player

## Constants ------------------------------------------------------------------

const DROP_PROTECTION_TIME := 0.75        # seconds during which you cannot re-pick your own drop
const INVENTORY_SIZE := 10
const DEFAULT_AXE_SCENE: PackedScene = preload("res://scenes/item/axe/axe_item.tscn")


## Signals --------------------------------------------------------------------

signal item_protection_expired


## Node references ------------------------------------------------------------

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var background: TileInteractor = %Background
@onready var item_pivot: Node2D = $ItemPivot
@onready var hotbar_ui: Control = $UI/HotbarUI
@onready var inventory_comp: InventoryComponent = $InventoryComponent

# Dictionary: pickup_node -> remaining_time
@onready var just_dropped: Dictionary = {}


## Inventory and player state -------------------------------------------------

var inventory_slots: Array[ItemData] = []
var selected_slot: int = 0
var _current_interactable: InteractableComponent = null

@export var SPEED: float = 150.0

var current_direction := "down"
var is_moving := false
var player_id: int

@export var current_item: HeldItem = null


## Lifecycle ------------------------------------------------------------------

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		$Camera2D.make_current()
	else:
		$Camera2D.set_enabled(false)

	add_to_group("players")


func _ready() -> void:
	# Initialize inventory reference and hotbar
	if inventory_comp:
		inventory_comp.inventory_changed.connect(_on_inventory_changed)
		inventory_slots = inventory_comp.slots
	else:
		inventory_slots.resize(INVENTORY_SIZE)
		for i in range(INVENTORY_SIZE):
			inventory_slots[i] = null
	
	_update_hotbar()


## Physics / Input ------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return

	var direction := Input.get_vector("left", "right", "up", "down").normalized()

	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	is_moving = velocity != Vector2.ZERO

	if velocity.x != 0:
		current_direction = "right" if velocity.x > 0 else "left"
	elif velocity.y != 0:
		current_direction = "down" if velocity.y > 0 else "up"

	update_animation()
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return

	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_change_selected_slot(-1)
			MOUSE_BUTTON_WHEEL_DOWN:
				_change_selected_slot(1)

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: _set_selected_slot(0)
			KEY_2: _set_selected_slot(1)
			KEY_3: _set_selected_slot(2)
			KEY_4: _set_selected_slot(3)
			KEY_5: _set_selected_slot(4)
			KEY_6: _set_selected_slot(5)
			KEY_7: _set_selected_slot(6)
			KEY_8: _set_selected_slot(7)
			KEY_9: _set_selected_slot(8)
			KEY_0: _set_selected_slot(9)  # 0 = slot 10

	if event.is_action_pressed("interact"):
		if _current_interactable:
			_current_interactable.trigger.rpc(name.to_int())


func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return

	if Input.is_action_just_pressed("attack_primary"):
		if current_item:
			current_item.use_primary()

	if Input.is_action_just_pressed("attack_secondary"):
		if current_item:
			current_item.use_secondary()

	if Input.is_action_just_pressed("drop_item"):
		_request_drop_selected_item()

	if Input.is_action_just_pressed("drop_all_item"):
		_drop_all_items()

	if Input.is_action_just_pressed("drop_half_item"):
		_drop_half_item()
	
	_update_drop_protection(delta)
	_update_item_aim()


## Animation / Aiming ---------------------------------------------------------

func update_animation() -> void:
	var animation_key := "moving" if is_moving else "idle"
	animated_sprite.play(animation_key + "_" + current_direction)


func _update_item_aim() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	item_pivot.look_at(mouse_pos)
	item_pivot.rotation += PI / 2.0


## Equipment ------------------------------------------------------------------

@rpc("any_peer","call_local")
func equip_item(item_scene: PackedScene) -> void:
	if current_item:
		current_item.on_unequipped()
		rpc("destroy_for_everyone", current_item)
		current_item = null

	var item := item_scene.instantiate() as HeldItem
	rpc("add_child_for_everyone", item_pivot, item)

	item.set_multiplayer_authority(get_multiplayer_authority())
	item.on_equipped()

	current_item = item


## Inventory management -------------------------------------------------------

func add_item(data: ItemData) -> bool:
	if inventory_comp:
		return inventory_comp.add_item(data)

	for i in range(INVENTORY_SIZE):
		if inventory_slots[i] == null:
			inventory_slots[i] = data
			_update_hotbar()
			return true

	return false


func remove_item(slot_idx: int) -> ItemData:
	if inventory_comp:
		return inventory_comp.removed_item(slot_idx)

	if slot_idx < 0 or slot_idx >= INVENTORY_SIZE:
		return null

	var data: ItemData = inventory_slots[slot_idx]
	inventory_slots[slot_idx] = null
	_update_hotbar()
	return data


## Dropping items -------------------------------------------------------------

func _request_drop_selected_item() -> void:
	var server_id := 1
	rpc_id(server_id,"rpc_drop_item",selected_slot)


@rpc("any_peer", "call_local")
func rpc_drop_item(slot_index: int) -> void:
	# This method runs on the SERVER's Player instance
	if !is_multiplayer_authority():
		return  # ignore if somehow called on a non-authority copy
	
	_drop_selected_item_on_server(slot_index)


func _drop_selected_item_on_server(slot_index: int) -> void:
	var data: ItemData = inventory_comp.get_slot(slot_index) if inventory_comp else inventory_slots[slot_index]
	if not data:
		return

	# Remove from inventory on server copy
	remove_item(slot_index)

	# Spawn world pickup **under the WorldItems container** so MultiplayerSpawner syncs it.
	if data.world_pickup_scene:
		var pickup := data.world_pickup_scene.instantiate() as WorldPickup
		var world_items_root := get_tree().root.get_node("Main/WorldItems") # adjust path
		world_items_root.add_child(pickup)
	
		pickup.global_position = global_position
		pickup.item_data = data
	
		_track_dropped_pickup(pickup)  # your existing drop protection logic




func _drop_all_items() -> void: # todo
	pass


func _drop_half_item() -> void: # todo
	pass

@rpc("any_peer", "call_local")
func rpc_pickup_item(pickup_path: NodePath) -> void:
	var pickup := get_tree().get_root().get_node_or_null(pickup_path) as WorldPickup
	if pickup == null:
		return  # already taken by someone else or deleted

	# Optional: server-side equivalent of drop protection
	if just_dropped.has(pickup):
		return

	# Try to add to this player's inventory on server
	if inventory_comp.add_item(pickup.item_data):
		rpc("destroy_for_everyone", pickup)



## Hotbar handling ------------------------------------------------------------

func _change_selected_slot(delta: int) -> void:
	var new_slot := (selected_slot + delta + INVENTORY_SIZE) % INVENTORY_SIZE
	set_equipped_slot.rpc(new_slot)


func _set_selected_slot(index: int) -> void:
	if index < 0 or index >= INVENTORY_SIZE:
		return

	set_equipped_slot.rpc(index)


@rpc("call_local")
func set_equipped_slot(index: int) -> void:
	selected_slot = index
	_equip_selected_item()
	_update_hotbar()


func _equip_selected_item() -> void:
	var data: ItemData = inventory_comp.get_slot(selected_slot) if inventory_comp else inventory_slots[selected_slot]

	if data and data.held_scene:
		rpc("equip_item",data.held_scene)
	else:
		if current_item:
			current_item.on_unequipped()
			rpc("destroy_for_everyone", current_item)
			current_item = null


func _update_hotbar() -> void:
	if hotbar_ui:
		var slots_ref := inventory_comp.slots if inventory_comp else inventory_slots
		hotbar_ui.call("set_slots", slots_ref)
		hotbar_ui.call("set_selected_index", selected_slot)


func _on_inventory_changed() -> void:
	if inventory_comp:
		inventory_slots = inventory_comp.slots
	_update_hotbar()


## Interaction ---------------------------------------------------------------

func set_current_interactable(inter: InteractableComponent) -> void:
	_current_interactable = inter


func clear_current_interactable(inter: InteractableComponent) -> void:
	if _current_interactable == inter:
		_current_interactable = null


## Drop protection ------------------------------------------------------------

func _update_drop_protection(delta: float) -> void:
	var to_remove: Array = []

	for pickup in just_dropped.keys():
		just_dropped[pickup] -= delta
		if just_dropped[pickup] <= 0.0:
			to_remove.append(pickup)
			item_protection_expired.emit()

	for p in to_remove:
		just_dropped.erase(p)


func _track_dropped_pickup(pickup: Node2D) -> void:
	just_dropped[pickup] = DROP_PROTECTION_TIME

	if not pickup.tree_exited.is_connected(_on_dropped_pickup_freed):
		pickup.tree_exited.connect(_on_dropped_pickup_freed.bind(pickup))


func _on_dropped_pickup_freed(pickup: Node2D) -> void:
	just_dropped.erase(pickup)


@rpc("any_peer", "call_local")
func destroy_for_everyone(node:Node) -> void:
	node.queue_free()

@rpc("any_peer", "call_local")
func add_child_for_everyone(node: Node, child: Node) -> void:
	node.add_child(child)
