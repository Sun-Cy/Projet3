extends Area2D
class_name AttackComponent

# To use
# Add a Collision2D to the Attack component
# Change the Value
# Use an animation player to animate the attack and call attack_once()


@export var attack_damage: float = 5.0
@export var knockback_force: float = 200.0

var _is_attacking: bool = false

func attack_once() -> void:
	#print("Bodies:", get_overlapping_bodies())
	#print("Areas:", get_overlapping_areas())
	
	if _is_attacking:
		return
	
	_is_attacking = true
	
	for area in get_overlapping_areas():
		_apply_hit(area)
	
	_is_attacking = false

func _build_attack() -> Attack:
	var attack := Attack.new()
	attack.attack_damage = attack_damage
	attack.knockback_force = knockback_force
	attack.attack_position = global_position
	return attack

func _apply_hit(target: Node) -> void:
	var hitbox: HitboxComponent = null
	
	if target is HitboxComponent:
		hitbox = target
	elif target.has_node("HitboxComponent"):
		hitbox = target.get_node("HitboxComponent") as HitboxComponent
	
	if hitbox:
		hitbox.damage(_build_attack())
