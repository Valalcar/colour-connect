extends Node2D

@onready var background_layer: TileMapLayer = $Layers/BackgroundLayer
@onready var section_panel: Panel = $Camera2D/SectionPanel

const SECTION_BOARD = preload("res://SquaresBoard/SectionBoard/section-board.tscn")
const SECTIONS_PATH = "res://SquaresBoard/sections/"

var sections : Array[SectionData]
var opened_section: SquaresBoard
var opened_section_data: SectionData

var sections_dictionary = {}

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
		var start = section_data.cell_start
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
		var cell_start = section.cell_start
		for pos_x in range(section.width):
			for pos_y in range(section.height):
				var cell = cell_start + Vector2i(pos_x, pos_y)
				sections_dictionary[cell] = section
				background_layer.set_cell(cell, 1, Vector2i.ZERO)
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		close_section()
	
	if opened_section != null:
		return
	
	if event.is_action_released("lmb"):
		var mouse_cell = background_layer.local_to_map(get_global_mouse_position())
		handle_click(mouse_cell)
	
func handle_click(cell: Vector2i):
	var clicked_section = sections.filter(func (s: SectionData): return s.cell_start.x <= cell.x && s.cell_start.y <= cell.y && s.cell_start.x + s.width > cell.x && s.cell_start.y + s.height > cell.y)
	if clicked_section.is_empty():
		return;
	open_section(clicked_section.front())
	
func open_section(section_data: SectionData) -> void:
	opened_section_data = section_data
	var section = SECTION_BOARD.instantiate()
	section.section_data = section_data
	section.saved_section.connect(save_section)
	opened_section = section
	#section_panel.position = camera_2d.position
	section_panel.add_child(section)
	section_panel.visible = true

func save_section(saved_data):
	print("TODO: Save Data")

func close_section():
	opened_section.queue_free()
	section_panel.visible = false
