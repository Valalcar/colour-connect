extends Camera2D

const speed = 100

func _process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += (direction * speed * delta)
