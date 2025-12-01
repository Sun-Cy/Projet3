extends Node2D
class_name HealthComponent

# How to
# add to the scene
# Change Max health and assigne a animation player if you want a damage animation
# Require a hitbox to receive damage

@export var MAX_HEALTH: float = 10.0
@export var animation: AnimationPlayer

var health: float      # export so MultiplayerSynchronizer can see it

signal health_changed(current: float, max: float)
signal died

func _ready() -> void:
	# Only the authority should initialize the true health value.
	if is_multiplayer_authority():
		health = MAX_HEALTH
		health_changed.emit(health, MAX_HEALTH)
	# Non-authoritative copies will get `health` from MultiplayerSynchronizer.
	if animation:
		animation.animation_finished.connect(_on_anim_finished)


func damage(attack: Attack) -> void:
	# Central authority check: only authority is allowed to actually change health.
	if is_multiplayer_authority():
		_apply_damage(attack.attack_damage)
	else:
		# Forward the damage request to whoever is authoritative for this component.
		# Only send plain values over the network, not the Attack object itself.
		rpc_id(
			get_multiplayer_authority(),
			"rpc_damage",
			attack.attack_damage
		)


@rpc("any_peer", "call_local")
func rpc_damage(damage_amount: float) -> void:
	# This runs on the authoritative HealthComponent.
	_apply_damage(damage_amount)


func _apply_damage(damage_amount: float) -> void:
	health = clampf(health - damage_amount, 0.0, MAX_HEALTH)
	health_changed.emit(health, MAX_HEALTH)
	
	if health == 0.0:
		died.emit()
		if animation and animation.has_animation("died"):
			animation.play("died")
		else:
			destroy_for_everyone()
	else:
		if animation and animation.has_animation("damage"):
			animation.play("damage")


func kill() -> void:
	health = 0.0
	health_changed.emit(health, MAX_HEALTH)
	died.emit()
	if animation and animation.has_animation("died"):
		animation.play("died")
	else:
		rpc("destroy_for_everyone")



@rpc("any_peer", "call_local")
func destroy_for_everyone() -> void:
	get_parent().queue_free()


func _on_anim_finished(anim_name: StringName) -> void:
	# Only authority decides when to destroy
	if not is_multiplayer_authority():
		return

	# Only act on the "died" animation
	if anim_name == "died":
		rpc("destroy_for_everyone")
