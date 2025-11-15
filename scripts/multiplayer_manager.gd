extends MultiplayerSpawner

var peer := ENetMultiplayerPeer.new()

@export var player_scene: PackedScene


@onready var create_server: Button = %CreateServer
@onready var create_client: Button = %CreateClient


func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)

func start_server():
	peer.create_server(4242, 32)
	multiplayer.multiplayer_peer = peer
	spawn_player(1)

func join_server(ip):
	peer.create_client(ip, 4242)
	multiplayer.multiplayer_peer = peer


func _on_create_client_pressed() -> void:
	join_server("localhost")
	create_server.visible = false
	create_client.visible = false


func _on_create_server_pressed() -> void:
	start_server()
	create_server.visible = false
	create_client.visible = false
	

func spawn_player(id: int):
	if !multiplayer.is_server(): return
	
	var player: Player = player_scene.instantiate()
	player.name = str(id)
	
	get_node(spawn_path).call_deferred("add_child", player)
