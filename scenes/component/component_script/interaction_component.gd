extends Area2D
class_name InteractableComponent

@export var interaction_range: float = 10

var _players: Array[Node2D] = []
var prompt_text: String = "[E]"
var player_group: StringName = &"players"
@onready var int_label: Label = $InteractionLabel

signal  focus_gained(player: Node2D)
signal focus_lost(player: Node2D)

func _ready() -> void:
	int_label.text = prompt_text
	int_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	
	shape.radius = interaction_range
	collision.shape = shape
	
	add_child(collision)


func _process(delta: float) -> void:
	if _players.is_empty():
		int_label.visible = false
	else:
		int_label.visible = true


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(player_group):
		return
	if body in _players:
		return
	
	_players.append(body)
	
	focus_gained.emit(body)
	
	# show the node to the player
	if body.has_method("set_current_interactable"):
		body.set_current_interactable(self)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group(player_group):
		return
	if body not in _players:
		return
	
	_players.erase(body)
	focus_lost.emit(body)
	
	if body.has_method("clear_current_interactable"):
		body.clear_current_interactable(self)


func trigger(actor: Node2D) -> void:
	if owner and owner.has_method("interact"):
		owner.interact(actor)
