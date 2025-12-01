extends Control

# Will be assigned in _ready() so script doesn't error if the node is missing
var slots_node: HBoxContainer = null
var selected_index: int = 0
var slot_controls: Array = []
var default_slot_texture: Texture = null

func _get_default_slot_texture() -> Texture:
	if default_slot_texture:
		return default_slot_texture
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			img.set_pixel(x, y, Color(0.18, 0.18, 0.18, 1))
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	default_slot_texture = tex
	return default_slot_texture

func _ready() -> void:
	# Ensure `Slots` HBoxContainer exists; create it if missing
	if has_node("Slots"):
		slots_node = $Slots
	else:
		slots_node = HBoxContainer.new()
		slots_node.name = "Slots"
		add_child(slots_node)
		# Add a few placeholder slot controls so the UI is visible immediately
		for i in range(5):
			var panel = Panel.new()
			panel.name = "Slot" + str(i)
			panel.custom_minimum_size = Vector2(40, 40)
			# default style: transparent background + gray border
			var sb = StyleBoxFlat.new()
			sb.bg_color = Color(0, 0, 0, 0)
			sb.border_width_top = 2
			sb.border_width_bottom = 2
			sb.border_width_left = 2
			sb.border_width_right = 2
			sb.border_color = Color(0.5, 0.5, 0.5)
			panel.add_theme_stylebox_override("panel", sb)
			# icon inside panel
			var tex = TextureRect.new()
			tex.name = "Icon"
			tex.expand = true
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex.texture = _get_default_slot_texture()
			# TextureRect will expand inside the Panel; rely on expand and min size
			tex.custom_minimum_size = Vector2(40, 40)
			panel.add_child(tex)
			slots_node.add_child(panel)
			slot_controls.append(panel)

	# If Slots existed but slot_controls is empty, populate references
	if slot_controls.size() == 0:
		for child in slots_node.get_children():
			slot_controls.append(child)

	# Keep initial layout; will be populated by `set_slots` when appropriate
	_update_selection()

	# Ensure the hotbar control is visible and in front
	visible = true
	show()
	# Some Godot versions don't expose `raise()` on Control/CanvasItem;
	# use `z_index` to bring it forward instead.
	z_index = 100

func set_slots(slots: Array) -> void:
	# Rebuild slot visuals from the provided array of ItemData (or null)
	for child in slots_node.get_children():
		child.queue_free()
	slot_controls.clear()

	for i in range(slots.size()):
		var slot_data = slots[i]
		var panel = Panel.new()
		panel.name = "Slot" + str(i)
		panel.custom_minimum_size = Vector2(40, 40)
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_color = Color(0.5, 0.5, 0.5)
		panel.add_theme_stylebox_override("panel", sb)

		var tex = TextureRect.new()
		tex.name = "Icon"
		tex.expand = true
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# let the TextureRect expand to fill the panel area
		tex.custom_minimum_size = Vector2(40, 40)
		if slot_data and slot_data.icon:
			tex.texture = slot_data.icon
		else:
			tex.texture = _get_default_slot_texture()
		panel.add_child(tex)
		slots_node.add_child(panel)
		slot_controls.append(panel)

	_update_selection()

func set_selected_index(idx: int) -> void:
	selected_index = idx
	_update_selection()

func _update_selection() -> void:
	for i in range(slot_controls.size()):
		var ctrl = slot_controls[i]
		if i == selected_index:
			ctrl.modulate = Color(1, 1, 0.7) # highlighted
		else:
			ctrl.modulate = Color(1, 1, 1)
