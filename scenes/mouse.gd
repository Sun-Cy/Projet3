extends TileMapLayer
class_name TileInteractor

@onready var highlight = Node2D.new()
var current_player

func _process(_delta: float) -> void:
	highlight.queue_redraw()

func _on_highlight_draw():
	var mouse_pos = get_global_mouse_position()
	var tile_pos = local_to_map(mouse_pos)
	var world_pos = map_to_local(tile_pos)
	var tile_size = tile_set.tile_size
	var rect = Rect2(world_pos - Vector2(tile_size) / 2, Vector2(tile_size))
	
	var color = Color.WHITE
	if current_player:
		var player_tile_pos = local_to_map(current_player.global_position)
		var distance = tile_pos.distance_to(player_tile_pos)
		if distance < 4:
			color = Color.GREEN
		else:
			color = Color.RED
	
	highlight.draw_rect(rect, color, false, 2.0)

func _ready() -> void:
	add_child(highlight)
	highlight.z_index = 1
	highlight.draw.connect(_on_highlight_draw)
