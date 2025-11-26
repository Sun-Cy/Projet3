extends Node2D
class_name HealthComponent

@export var MAX_HEALTH:float = 10.0
var health: float

signal health_changed(current: float, max: float)
signal died

func _ready() -> void:
	health = MAX_HEALTH
	health_changed.emit(health, MAX_HEALTH)


func damage(attack: Attack) -> void:
	health = clampf(health - attack.attack_damage, 0.0, MAX_HEALTH)
	health_changed.emit(health, MAX_HEALTH)
	print(health)
	if health == 0.0:
		#play dead animation
		#drop loot
		died.emit()
		get_parent().queue_free()
		return
	
	#play damage animation
	
