extends Control

enum WindowMode { WINDOWED, BORDERLESS, FULLSCREEN }

var _waiting_button: Button = null
var _last_input: String = ""
var _waiting_for_action: StringName = &""

const CFG_PATH := "user://options.cfg"
var settings := {
	"display": {"mode": "windowed", "ui_scale": 1.0, "vsync": false, "fps_cap": 0},
	"audio":   {"master": 0.90, "music": 0.70, "sfx": 0.75, "ui": 0.80},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
	# Apply display
	_set_window_mode(settings.display.mode == "fullscreen", settings.display.mode == "borderless")
	_set_ui_scale(settings.display.ui_scale)
	_set_vsync(settings.display.vsync)
	_set_fps_cap(settings.display.fps_cap)

	# Apply audio
	_set_bus_volume("Master", settings.audio.master)
	_set_bus_volume("Music", settings.audio.music)
	_set_bus_volume("SFX", settings.audio.sfx)
	_set_bus_volume("UI", settings.audio.ui)


func _set_window_mode(fullscreen: bool, borderless: bool) -> void:
	var w := get_window()
	if fullscreen:
		# Real fullscreen — Godot will also set borderless=true internally.
		w.mode = Window.MODE_FULLSCREEN
		w.borderless = false  # (Optional) keep your non-FS states clean afterwards. 
		return
	
	# Windowed path
	w.mode = Window.MODE_WINDOWED
	w.borderless = borderless
	
	if borderless:
		# Make it *cover* the current screen: set size and move to (0,0) on that screen.
		var screen := w.current_screen
		size = DisplayServer.screen_get_size(screen)
		w.size = size
		w.position = DisplayServer.screen_get_position(screen)  # usually (0,0) for that monitor


func _set_ui_scale(f: float) -> void:
	get_tree().root.content_scale_factor = clamp(f, 0.75 , 1.5)


func _set_vsync(enable: bool) -> void:
	# Change at runtime via DisplayServer, not ProjectSettings.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if enable else DisplayServer.VSYNC_DISABLED)


func _set_fps_cap(cap: int) -> void:
	Engine.max_fps = max(0, cap)   # 0 = uncapped
	settings.display.fps_cap = Engine.max_fps


func _set_bus_volume(bus_name: String, linear_0_1: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1: return
	AudioServer.set_bus_volume_db(idx, linear_to_db(clamp(linear_0_1, 0.0, 1.0)))


func start_rebind(action: StringName, button: Button) -> void:
	_waiting_for_action = action
	_waiting_button = button
	button.text = "Press a key..."
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if _waiting_for_action == &"": return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Clear existing and add the new one
		InputMap.action_erase_events(_waiting_for_action)
		InputMap.action_add_event(_waiting_for_action, event)
		_last_input = event.as_text()
		
		# Update label text
		_last_input = event.as_text()
		if _waiting_button:
			_waiting_button.text = _last_input
		
		# Reset state
		_waiting_for_action = &""
		_waiting_button = null
		set_process_input(false)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	for section in settings.keys():
		for k in settings[section].keys():
			cfg.set_value(section, k, settings[section][k])
	cfg.save(CFG_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CFG_PATH)
	if err != OK: return
	for section in settings.keys():
		for k in settings[section].keys():
			settings[section][k] = cfg.get_value(section, k, settings[section][k])


# Button Connection
# Display
func _on_window_mode_item_selected(index: int) -> void:
	match index:
		WindowMode.WINDOWED:
			_set_window_mode(false, false)
			settings.display.mode = "windowed"
		WindowMode.BORDERLESS:
			_set_window_mode(false, true)
			settings.display.mode = "borderless"
		WindowMode.FULLSCREEN:
			_set_window_mode(true, false)
			settings.display.mode = "fullscreen"
	
	save_settings()


func _on_ui_scale_value_changed(value: float) -> void:
	_set_ui_scale(value)
	settings.display.ui_scale = value
	save_settings()


func _on_v_sync_toggled(toggled_on: bool) -> void:
	_set_vsync(toggled_on)
	settings.display.vsync = toggled_on
	%FPSCap.disabled = toggled_on
	
	if toggled_on:
		# With V-Sync ON, ignore/clear app-level cap.
		_set_fps_cap(0)                  # or Engine.max_fps = 0
		settings.display.fps_cap = 0
	else:
		# Re-apply the user’s cap when V-Sync is OFF.
		_set_fps_cap(settings.display.fps_cap)
		
	save_settings()


func _on_fps_cap_item_selected(index: int) -> void:
	match index:
		0: # 30 FPS
			_set_fps_cap(30)
		1: # 60 FPS
			_set_fps_cap(60)
		2: # 120 FPS
			_set_fps_cap(120)
		3: # 144 FPS
			_set_fps_cap(144)
		4: # 165 FPS
			_set_fps_cap(165)
		5: # Unlimited
			_set_fps_cap(0)
	
	save_settings()


func _on_master_audio_value_changed(value: float) -> void:
	_set_bus_volume("Master",value)
	settings.audio.master = value
	save_settings()


func _on_music_audio_value_changed(value: float) -> void:
	_set_bus_volume("Music",value)
	settings.audio.music = value
	save_settings()


func _on_sfx_audio_value_changed(value: float) -> void:
	_set_bus_volume("SFX",value)
	settings.audio.sfx = value
	save_settings()


func _on_ui_audio_value_changed(value: float) -> void:
	_set_bus_volume("UI",value)
	settings.audio.ui = value
	save_settings()


func _on_back_pressed() -> void:
	self.visible = false


func _on_move_up_button_pressed() -> void:
	start_rebind(&"up", %MoveUpButton)


func _on_move_down_button_pressed() -> void:
	start_rebind(&"down", %MoveDownButton)


func _on_move_left_button_pressed() -> void:
	start_rebind(&"left", %MoveLeftButton)


func _on_move_right_button_pressed() -> void:
	start_rebind(&"right", %MoveRightButton)


func _on_use_button_pressed() -> void:
	start_rebind(&"attack_primary", %UseButton)


func _on_special_use_button_pressed() -> void:
	start_rebind(&"attack_secondary", %SpecialUseButton)
