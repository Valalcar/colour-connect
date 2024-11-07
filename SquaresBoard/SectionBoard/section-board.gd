class_name SquaresBoard
extends Node2D

signal saved_section(section_data: SectionData)

const CELL_COLOUR_MAP = {
	"R": Vector2i(0, 0),
	"G": Vector2i(1, 1),
	"B": Vector2i(1, 0),
	"Y": Vector2i(0, 1)
}

@onready var background_layer: SquaresBackgroundLayer = $BackgroundLayer
@onready var pieces_placement_layer: PiecesPlacementLayer = $PiecesPlacementLayer
@onready var piece_preview_layer: TileMapLayer = $PiecePreviewLayer
@onready var border_layer: SquaresBorderLayer = $BorderLayer

@export var section_data: SectionData

var width: int = 8
var height: int = 8

var mouse_cell : Vector2i
var current_piece : Array

var is_finished : bool = false

func _ready() -> void:
	if section_data.finished:
		is_finished = true
		load_saved_board()
	else:
		get_new_piece()
		
	width = section_data.width
	height = section_data.height
	background_layer.draw_background(width, height)

func _input(event: InputEvent) -> void:
	if is_finished:
		return
	
	if event is InputEventMouseMotion:
		handle_mouse_hover()
	elif event.is_action_released("rmb"):
		rotate_piece()
	elif event.is_action_released("lmb"):
		place_piece()
	elif event.is_action_released("num1"):
		save_board()
	preview_piece_placement()

func handle_mouse_hover() -> void:
	var mouse_pos = background_layer.to_local(get_global_mouse_position())
	var current_mouse_cell = background_layer.local_to_map(mouse_pos)
	if current_mouse_cell != mouse_cell && piece_is_inside_area(current_mouse_cell):
		mouse_cell = current_mouse_cell
		preview_piece_placement()

func piece_is_inside_area(reference_cell: Vector2i) -> bool:
	for line_n in current_piece.size():
		for col_n in current_piece[line_n].size():
			var cell = Vector2(reference_cell.x + (col_n/2), reference_cell.y + (line_n/2))
			if cell.x < 0 || cell.x >= width || cell.y < 0 || cell.y >= height:
				return false
	return true

func preview_piece_placement() -> void:
	piece_preview_layer.clear()
	for line_n in current_piece.size():
		for col_n in current_piece[line_n].size():
			var board_cell = (2*mouse_cell) + Vector2i(col_n, line_n)
			var colour_piece = CELL_COLOUR_MAP[current_piece[line_n][col_n]]
			piece_preview_layer.set_cell(board_cell, 0, colour_piece)

func place_piece() -> void:
	if (!check_piece()):
		return
	var placement_cells = piece_preview_layer.get_used_cells()
	for preview_cell in placement_cells:
		var atlas_cell = piece_preview_layer.get_cell_atlas_coords(preview_cell)
		pieces_placement_layer.set_cell(preview_cell, 0, atlas_cell)
	pieces_placement_layer.remap_groups(placement_cells)
	pieces_placement_layer.remap_borders(placement_cells)
	
	get_new_piece()

func check_piece() -> bool:
	var used_cells = pieces_placement_layer.get_used_cells()
	for preview_cell in piece_preview_layer.get_used_cells():
		if used_cells.has(preview_cell):
			return false
	return true

func rotate_piece() -> void:
	var prev_height = current_piece.size()
	var prev_width = current_piece.front().size()
	var rotated_piece = []
	for row in range(prev_width):
		rotated_piece.push_back([])
	
	for prev_row in range(prev_width):
		for prev_line in range(prev_height):
			rotated_piece[prev_row].push_back(current_piece[prev_line][prev_row])
	rotated_piece.map(func (a: Array): a.reverse())
	current_piece = rotated_piece
	return
		
func get_new_piece() -> void:
	var piece_types = [
	[[0, 0, 1, 1],[2, 2, 3, 3]],
	[[0, 1, 1, 2],[0, 3, 3, 2]]
	]
	var colour_options = ["R", "G", "B", "Y"]
	var selected_colours = []
	for i in range(4):
		selected_colours.push_back(colour_options.pick_random())
	var type = piece_types.pick_random()
	
	var result = []
	for line in type.size():
		result.push_back([])
		for row in type[line].size():
			var color_ref = type[line][row]
			var color = selected_colours[color_ref]
			result[line].push_back(color)
	current_piece = result

func load_saved_board() -> void:
	pieces_placement_layer.set_pattern(section_data.pattern_offset, section_data.pattern)
	pieces_placement_layer.remap_groups(pieces_placement_layer.get_used_cells())

func save_board() -> void :
	var used_cells = pieces_placement_layer.get_used_cells()
	var offset : Vector2i = used_cells.front()
	for cell in used_cells:
		if cell.x < offset.x:
			offset.x = cell.y
		if cell.y < offset.y:
			offset.y = cell.y
			
	section_data.pattern = pieces_placement_layer.get_pattern(used_cells)
	section_data.pattern_offset = offset
	section_data.groups = pieces_placement_layer.groups_result
	section_data.finished = true
	saved_section.emit(section_data)
