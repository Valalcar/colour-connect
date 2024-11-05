extends Camera2D

const speed = 100

@onready var section_panel: Panel = $SectionPanel

func _process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += (direction * speed * delta)

func adapt_to_view(section_size: Vector2) -> void:
	if section_size == Vector2.ZERO:
		zoom = Vector2.ONE
		return
	
	var viewport_size = get_viewport_rect().size
	var size_ratio = (viewport_size * 0.7) / (32 * section_size)
	var zoom_change = min(size_ratio.x, size_ratio.y)
	zoom = Vector2(zoom_change, zoom_change)
	print(zoom_change)
	
	section_panel.size = (viewport_size / zoom_change)*0.8
	section_panel.position = -section_panel.size/2
	
	
