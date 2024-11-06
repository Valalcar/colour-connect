class_name PiecesPlacementLayer
extends TileMapLayer

signal grouping_recalculated(groups: Array[SectionColorGroup])

const NEIGHBORS : Array[TileSet.CellNeighbor] = \
	[TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_TOP_SIDE]
	
@onready var border_layer: SquaresBorderLayer = $"../BorderLayer"

## List the groups present
# key: group identifier - one of the group cells
# value: Array[Vector2i] - list of cells belonging to group
var color_groups = {}

## Map to each group, each cell belongs
# key: cell Vector2i
# value: Vector2i - group identifier
var cells_group = {}

func remap_groups(new_cells: Array[Vector2i]) -> void:
	var unmaped_cells = new_cells.duplicate()
	for cell in new_cells:
		var cell_color = get_cell_atlas_coords(cell)
		var similar_neighbors : Array[Vector2i] = []
		for neighbor in NEIGHBORS:
			var neighbor_cell = get_neighbor_cell(cell, neighbor)
			##dont count cells in group that haven't been mapped yet
			if !unmaped_cells.has(neighbor_cell):
				var neighbor_color = get_cell_atlas_coords(neighbor_cell)
				if cell_color == neighbor_color:
					similar_neighbors.push_back(neighbor_cell)
		unmaped_cells.erase(cell)
		
		if similar_neighbors.is_empty():
			##Create new group
			color_groups[cell] = [cell]
			cells_group[cell] = cell
		elif similar_neighbors.size() == 1:
			##add cell to group
			var group = cells_group[similar_neighbors.front()]
			color_groups[group].push_back(cell)
			cells_group[cell] = group
		else:
			var group = cells_group[similar_neighbors.front()]
			color_groups[group].push_back(cell)
			cells_group[cell] = group
			join_groups(similar_neighbors)
			
	#TODO Rework to reuse the loop:
	# Borders need to be mapped alongside neighbors, while groups don't
	remap_borders(new_cells)
	
	build_groups_list()
	
func build_groups_list() -> void:
	const CELL_COLOUR_MAP = {
		Vector2i(0, 0): "Red",
		Vector2i(1, 1): "Green",
		Vector2i(1, 0): "Blue",
		Vector2i(0, 1): "Yellow"
	}
	var groups_results : Array[SectionColorGroup] = []
	for group_head_cell in color_groups:
		var atlas = get_cell_atlas_coords(group_head_cell)
		var color = CELL_COLOUR_MAP[atlas]
		var group_size = color_groups[group_head_cell].size()
		var group_result = SectionColorGroup.new()
		group_result.head_cell = group_head_cell
		group_result.color = color
		group_result.cells_count = group_size
		groups_results.push_back(group_result)
	grouping_recalculated.emit(groups_results)

func join_groups(cells_from_groups: Array[Vector2i]):
	var groups = cells_from_groups.map(func (c): return cells_group[c])
	var result_group = groups.pop_front()
	for group in groups:
		if group != result_group && color_groups.has(group):
			for cell in color_groups[group]:
				color_groups[result_group].push_back(cell)
				cells_group[cell] = result_group
			color_groups.erase(group)

func remap_borders(piece_cells: Array[Vector2i]):
	var cells_to_map : Dictionary = get_cells_and_direct_neighbors(piece_cells)
	var mapped_cells = {}
	var cells_similar_neighbors = {}
	for cell in cells_to_map:
		var cell_color = get_cell_atlas_coords(cell)
		var similar_neighbors = []
		var similar_neighbors_cells = []
		for neighbor in NEIGHBORS:
			var neighbor_cell = get_neighbor_cell(cell, neighbor)
			var neighbor_color = get_cell_atlas_coords(neighbor_cell)
			if cell_color == neighbor_color:
				similar_neighbors.push_back(neighbor)
				similar_neighbors_cells.push_back(neighbor_cell)
		mapped_cells[cell] = similar_neighbors_cells
		cells_similar_neighbors[cell] = similar_neighbors
	map_borders(cells_similar_neighbors)
	
func get_cells_and_direct_neighbors(cell_group: Array[Vector2i]) -> Dictionary:
	var cell_group_and_neighborhood = {}
	for cell in cell_group:
		cell_group_and_neighborhood[cell] = true
		var neighbors = get_cell_neighbors(cell)
		for neighbor in neighbors:
			cell_group_and_neighborhood[neighbor] = true
	return cell_group_and_neighborhood

func get_cell_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result : Array[Vector2i] = []
	result.assign(NEIGHBORS.map(func (n): return get_neighbor_cell(cell, n)))
	return result

func map_borders(cells_connections: Dictionary) -> void:
	for cell in cells_connections:
		var connections : Array[TileSet.CellNeighbor] = [] 
		connections.assign(cells_connections[cell])
		border_layer.set_tile_borders(cell, connections);
