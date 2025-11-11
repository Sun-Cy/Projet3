extends Control

const GAME_SCENE: PackedScene = preload("uid://b8q4k3g2kge6t")
const OPTION_SCENE: PackedScene = preload("res://scenes/option.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(GAME_SCENE)


func _on_option_pressed() -> void:
	get_tree().change_scene_to_packed(OPTION_SCENE)


func _on_quit_button_down() -> void:
	get_tree().quit(0)
