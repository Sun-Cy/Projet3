# res://items/axe_item.gd
extends HeldItem
class_name AxeItem

@export var anim_player: AnimationPlayer
@export var attack_component: AttackComponent

@export var attack_cooldown: float = 0.25
var _can_attack: bool = true

func on_equipped() -> void:
	# Optional: play an idle animation if you have one
	if anim_player.has_animation("idle"):
		anim_player.play("idle")

func on_unequipped() -> void:
	anim_player.stop()

func use_primary() -> void:
	if not _can_attack:
		return

	_can_attack = false
	anim_player.play("swing")  # Animation will control hitbox timing

func use_secondary() -> void:
	pass

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "swing":
		# Allow next swing
		var timer := get_tree().create_timer(attack_cooldown)
		timer.timeout.connect(func() -> void:
			_can_attack = true)
