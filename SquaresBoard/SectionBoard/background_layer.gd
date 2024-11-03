class_name SquaresBackgroundLayer
extends TileMapLayer

const SOURCE = 2
const OPEN_TILE = Vector2i(0, 0)
const CLOSED_TILE = Vector2i(0, 1)

func draw_background(width: int, height: int) -> void:
	clear()
	_draw_background_border(width, height) 
	for x_pos in range(width):
		for y_pos in range(height):
			set_cell(Vector2i(x_pos, y_pos), SOURCE, OPEN_TILE)

func _draw_background_border(width: int, height: int) -> void:
	for x_pos in range(-1, width + 1):
		set_cell(Vector2i(x_pos, -1), SOURCE, CLOSED_TILE)
		set_cell(Vector2i(x_pos, height), SOURCE, CLOSED_TILE)
	
	for y_pos in range(-1, height + 1):
		set_cell(Vector2i(-1, y_pos), SOURCE, CLOSED_TILE)
		set_cell(Vector2i(width, y_pos), SOURCE, CLOSED_TILE)
