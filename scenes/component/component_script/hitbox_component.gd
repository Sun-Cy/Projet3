extends Node2D
class_name HitboxComponent

# How to
# add it to the scene
# Add a CollisionShape2D
# assign a Health Component

@export var health_component: HealthComponent

func damage(attack: Attack) -> void:
	if health_component:
		health_component.damage(attack)
