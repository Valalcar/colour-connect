class_name PlanetBoard
extends Node2D

@onready var background_layer: TileMapLayer = $Layers/BackgroundLayer
@onready var drawn_squares_layer: TileMapLayer = $Layers/DrawnSquaresLayer
@onready var section_panel: Panel = $Camera2D/SectionPanel
@onready var panel: Panel = $Camera2D/Panel

@onready var camera_2d: Camera2D = $Camera2D

const SECTION_BOARD = preload("res://SquaresBoard/SectionBoard/section-board.tscn")
const SECTIONS_PATH = "res://SquaresBoard/sections/"

var sections : Array[SectionData]
var opened_section: SquaresBoard
var opened_section_data: SectionData

var sections_dictionary = {}

var drag_start: Vector2i
var is_dragging_mouse: bool = false

func _ready() -> void:
	load_sections()

func load_sections():
	background_layer.clear()
	var min_x = 0
	var min_y = 0
	var max_x = 0
	var max_y = 0
	for section_file in DirAccess.get_files_at(SECTIONS_PATH):
		var section_data: SectionData = load(SECTIONS_PATH + section_file)
		sections.push_back(section_data)
		var start = section_data.world_head_cell
		var end = start + Vector2i(section_data.width, section_data.height)
		if min_x > start.x:
			min_x = start.x
		if min_y > start.y:
			min_y = start.y
		if max_x < end.x:
			max_x = end.x
		if max_y < end.y:
			max_y = end.y
	for pos_x in range(min_x - 1, max_x + 1):
		for pos_y in range(min_y - 1, max_y + 1):
			background_layer.set_cell(Vector2i(pos_x, pos_y), 1, Vector2i.RIGHT)
			pass
	
	for section in sections:
		var cell_start = section.world_head_cell
		for pos_x in range(section.width):
			for pos_y in range(section.height):
				var cell = cell_start + Vector2i(pos_x, pos_y)
				sections_dictionary[cell] = section
				background_layer.set_cell(cell, 1, Vector2i.ZERO)

func get_pattern() -> TileMapPattern:
	return drawn_squares_layer.get_pattern(drawn_squares_layer.get_used_cells())

func get_patern_offset() -> Vector2i:
	var used_cells = drawn_squares_layer.get_used_cells()
	var offset : Vector2i = used_cells.front()
	for cell in used_cells:
		if cell.x < offset.x:
			offset.x = cell.y
		if cell.y < offset.y:
			offset.y = cell.y
	return offset

func load_game(saved_game: SavedGame):
	drawn_squares_layer.clear()
	sections = saved_game.sections
	drawn_squares_layer.set_pattern(saved_game.pattern_offset, saved_game.pattern)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		close_section()
		return
	
	if opened_section != null:
		return

	if event.is_action_pressed("lmb"):
		drag_start = background_layer.local_to_map(get_global_mouse_position())
		
	if event.is_action_released("lmb"):
		var mouse_cell = background_layer.local_to_map(get_global_mouse_position())
		handle_click(mouse_cell)
	
func handle_click(cell: Vector2i):
	if sections_dictionary.has(cell):
		open_section(sections_dictionary[cell])
	else:
		handle_hold_and_drag(cell)
		
func handle_hold_and_drag(drag_stop: Vector2i):
	var selected_cells: Array[Vector2i] = get_selected_cells(drag_stop)
	if selected_cells.size() < 2:
		return
	for cell in selected_cells:
		if sections_dictionary.has(cell):
			return;
	create_new_section(selected_cells)

func get_selected_cells(drag_stop: Vector2i) -> Array[Vector2i]:
	var cells : Array[Vector2i] = []
	var min_x = mini(drag_start.x, drag_stop.x)
	var max_x = maxi(drag_start.x, drag_stop.x) + 1
	var min_y = mini(drag_start.y, drag_stop.y)
	var max_y = maxi(drag_start.y, drag_stop.y) + 1
	for cell_x in range(min_x, max_x):
		for cell_y in range(min_y, max_y):
			cells.push_back(Vector2i(cell_x, cell_y))
	return cells

func create_new_section(cells: Array[Vector2i]) -> void:
	var cell_start = cells.front()
	var cell_end = cells.front()
	for cell in cells:
		if cell.x < cell_start.x:
			cell_start.x = cell.x
		if cell.y < cell_start.y:
			cell_start.y = cell.y
		if cell.x > cell_end.x:
			cell_end.x = cell.x
		if cell.y > cell_end.y:
			cell_end.y = cell.y
	
	var section_data = SectionData.new()
	section_data.world_head_cell = cell_start
	section_data.width = (cell_end.x - cell_start.x + 1)
	section_data.height = (cell_end.y - cell_start.y + 1)
	sections.push_back(section_data)
	sections_dictionary[cell_start] = section_data
	open_section(section_data)

func open_section(section_data: SectionData) -> void:
	opened_section_data = section_data
	var section = SECTION_BOARD.instantiate()
	section.section_data = section_data
	section.saved_section.connect(save_section)
	opened_section = section
	
	var section_size = Vector2(section_data.width, section_data.height)
	camera_2d.adapt_to_view(section_size)
	section_panel.add_child(section)
	section.position = section_panel.size/2 - (32*section_size)/2
	section_panel.visible = true
	panel.visible = true
	
func save_section(section_data: SectionData):
	var pattern: TileMapPattern = section_data.pattern
	var pattern_offset: Vector2i = section_data.pattern_offset
	var section_start: Vector2i = section_data.world_head_cell
	drawn_squares_layer.set_pattern(2*section_start + pattern_offset, pattern)

func close_section():
	if is_instance_valid(opened_section):
		opened_section.queue_free()
		section_panel.visible = false
		panel.visible = false
		camera_2d.adapt_to_view(Vector2.ZERO)
