extends StaticBody2D

@onready var health: HealthComponent = $HealthComponent

func _ready() -> void:
	health.died.connect(_on_died)

func _on_died() -> void:
	if is_multiplayer_authority():
		rpc("destroy_for_everyone")

@rpc("any_peer", "call_local")
func destroy_for_everyone() -> void:
	queue_free()
