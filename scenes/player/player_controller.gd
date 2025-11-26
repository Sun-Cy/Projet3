extends CharacterBody2D
class_name Player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var background: TileInteractor = %Background
@onready var item_pivot: Node2D = $ItemPivot

@export var SPEED: float = 150.0

var current_direction = "down"
var is_moving = false
@export var current_item: HeldItem = null

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		$Camera2D.make_current()
	else:
		$Camera2D.set_enabled(false)


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	var direction := Input.get_vector("left", "right", "up", "down").normalized().round()
	
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


func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	_update_item_aim()
	
	if Input.is_action_just_pressed("attack_primary"):   # LMB
		if current_item:
			current_item.use_primary()
	
	if Input.is_action_just_pressed("attack_secondary"): # RMB
		if current_item:
			current_item.use_secondary()


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
	item.on_equipped()

	current_item = item
