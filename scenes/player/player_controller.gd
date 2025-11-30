extends CharacterBody2D
class_name Player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var background: TileInteractor = %Background
@onready var item_pivot: Node2D = $ItemPivot
@onready var hotbar_ui: Control = $UI/HotbarUI

const INVENTORY_SIZE := 10
var inventory_slots: Array[ItemData] = []
@onready var inventory_comp: InventoryComponent = $InventoryComponent
var selected_slot: int = 0
var _current_interactable: InteractableComponent = null

@export var SPEED: float = 150.0

var current_direction = "down"
var is_moving = false
var player_id: int
@export var current_item: HeldItem = null

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
		# Keep a direct reference to the slots array for convenience
		inventory_slots = inventory_comp.slots
	else:
		# fallback: ensure inventory_slots has the right size
		inventory_slots.resize(INVENTORY_SIZE)
		for i in range(INVENTORY_SIZE):
			inventory_slots[i] = null

	_update_hotbar()

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	
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
	
	if event.is_action_pressed("interact"):  # interaction
		if _current_interactable:
			_current_interactable.trigger(self)


func _process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	_update_item_aim()
	
	if Input.is_action_just_pressed("attack_primary"):   # LMB
		if current_item:
			current_item.use_primary()
	
	if Input.is_action_just_pressed("attack_secondary"): # RMB
		if current_item:
			current_item.use_secondary()
	
	if Input.is_action_just_pressed("drop_item"):
		_drop_selected_item()
	
	if Input.is_action_just_pressed("drop_all_item"):
		_drop_all_items()
	
	if Input.is_action_just_pressed("drop_half_item"):
		_drop_half_item()


func update_animation():
	var animation_key = "moving" if is_moving else "idle"
	animated_sprite.play(animation_key + "_" + current_direction);


func _update_item_aim() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	item_pivot.look_at(mouse_pos)
	item_pivot.rotation += PI/2


func equip_item(item_scene: PackedScene) -> void:
	if current_item:
		current_item.on_unequipped()
		current_item.queue_free()
		current_item = null
	
	var item: HeldItem = item_scene.instantiate() as HeldItem
	$ItemPivot.add_child(item)
	
	item.set_multiplayer_authority(get_multiplayer_authority())
	
	item.on_equipped()
	current_item = item


func add_item(data: ItemData) -> bool:
	# Try to insert through the InventoryComponent if available
	if inventory_comp:
		return inventory_comp.add_item(data)

	# Fallback: find first empty slot
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
	var d = inventory_slots[slot_idx]
	inventory_slots[slot_idx] = null
	_update_hotbar()
	return d


func _drop_selected_item() -> void:
	var data: ItemData = inventory_comp.get_slot(selected_slot) if inventory_comp else inventory_slots[selected_slot]
	if not data:
		return
	# spawn world pickup if available
	if data.world_pickup_scene:
		var pickup = data.world_pickup_scene.instantiate()
		get_parent().add_child(pickup)
		pickup.global_position = global_position
	remove_item(selected_slot)


func _drop_all_items() -> void:
	if inventory_comp:
		for i in range(inventory_comp.slot_count):
			var d = inventory_comp.removed_item(i)
			if d and d.world_pickup_scene:
				var p = d.world_pickup_scene.instantiate()
				get_parent().add_child(p)
				p.global_position = global_position
	else:
		for i in range(INVENTORY_SIZE):
			if inventory_slots[i]:
				if inventory_slots[i].world_pickup_scene:
					var p2 = inventory_slots[i].world_pickup_scene.instantiate()
					get_parent().add_child(p2)
					p2.global_position = global_position
				inventory_slots[i] = null
	_update_hotbar()


func _drop_half_item() -> void:
	# No stack counts implemented: treat as dropping selected item
	_drop_selected_item()


# function related to hotbar
func _change_selected_slot(delta: int) -> void:
	selected_slot = (selected_slot + delta + INVENTORY_SIZE) % INVENTORY_SIZE
	_equip_selected_item()
	_update_hotbar()

func _set_selected_slot(index: int) -> void:
	if index < 0 or index >= INVENTORY_SIZE:
		return
	selected_slot = index
	_equip_selected_item()
	_update_hotbar()


func _equip_selected_item() -> void:
	var data: ItemData = inventory_comp.get_slot(selected_slot) if inventory_comp else inventory_slots[selected_slot]
	if data and data.held_scene:
		equip_item(data.held_scene)
	else:
		# No item in this slot → clear hand
		if current_item:
			current_item.on_unequipped()
			current_item.queue_free()
			current_item = null


func _update_hotbar() -> void:
	if hotbar_ui:
		var slots_ref = inventory_comp.slots if inventory_comp else inventory_slots
		hotbar_ui.call("set_slots", slots_ref)
		hotbar_ui.call("set_selected_index", selected_slot)


func _on_inventory_changed() -> void:
	if inventory_comp:
		inventory_slots = inventory_comp.slots
	_update_hotbar()


# Function to interact with object
func set_current_interactable(inter: InteractableComponent) -> void:
	_current_interactable = inter


func clear_current_interactable(inter: InteractableComponent) -> void:
	if _current_interactable == inter:
		_current_interactable = null
