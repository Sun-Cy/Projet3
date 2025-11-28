extends CanvasLayer

@export var debug_label: Label

var is_debug_mode := false
var player: CharacterBody2D

func _ready() -> void:
	debug_label.visible = false
	player = get_parent()
	print(player)
	if not player.is_multiplayer_authority():
		queue_free()
		return


func _process(delta: float) -> void:
	if is_debug_mode:
		_debug_text(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_overlay"):
		is_debug_mode = !is_debug_mode
		debug_label.visible = is_debug_mode


func _debug_text(delta: float):
	var fps := Engine.get_frames_per_second()
	var frame_ms := delta * 1000.0
	
	var player_pos :Vector2= player.global_position if player else Vector2.ZERO
	var player_vel :Vector2= Vector2.ZERO
	if player and player is CharacterBody2D:
		player_vel = player.velocity
	
	# Example multiplayer info (if you are using MultiplayerAPI)
	var mp := get_tree().get_multiplayer()
	var is_server := mp.is_server()
	var unique_id := mp.get_unique_id()
	
	# You can expand this with anything you need
	var text := ""
	text += "DEBUG OVERLAY (F3)\n"
	text += "----------------------\n"
	text += "FPS: %.1f (%.2f ms)\n" % [fps, frame_ms]
	text += "Window size: %s\n" % [DisplayServer.window_get_size()]
	text += "\n"
	text += "Player pos: (%.1f, %.1f)\n" % [player_pos.x, player_pos.y]
	text += "Player vel: (%.1f, %.1f)\n" % [player_vel.x, player_vel.y]
	text += "\n"
	text += "Multiplayer:\n"
	text += "- Is server: %s\n" % [str(is_server)]
	text += "- Peer ID: %d\n" % [unique_id]
	# You could add: mp.get_peers() count, etc.
	
	# Example of performance monitors via Performance singleton:
	# var mem := Performance.get_monitor(Performance.MEMORY_STATIC)
	# text += "\nMemory (static): %.0f KB\n" % [mem / 1024.0]
	debug_label.text = text
