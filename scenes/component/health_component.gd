extends Node2D
class_name HealthComponent

@export var MAX_HEALTH:float = 10.0
@export var animation: AnimationPlayer
var health: float

signal health_changed(current: float, max: float)
signal died

func _ready() -> void:
	health = MAX_HEALTH
	health_changed.emit(health, MAX_HEALTH)


func damage(attack: Attack) -> void:
	health = clampf(health - attack.attack_damage, 0.0, MAX_HEALTH)
	health_changed.emit(health, MAX_HEALTH)
	
	if health == 0.0:
		died.emit()
		if animation:
			if animation.has_animation("died"):
				animation.play("died")
		return
	
	if animation:
		if animation.has_animation("damage"):
			animation.play("damage")
	
