extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0

var current_direction = "down"
var is_moving = false


func _physics_process(delta: float) -> void:
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

func update_animation():
	var animation_key = "moving" if is_moving else "idle"
	animated_sprite.play(animation_key + "_" + current_direction);
