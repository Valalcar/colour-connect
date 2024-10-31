class_name BorderLayer
extends TileMapLayer

const SOURCE := 0
## Tilemaps can be redrawn and setup to use just one of these
## Cell Neighbor values
## CELL_NEIGHBOR_RIGHT_SIDE = 0
## CELL_NEIGHBOR_BOTTOM_SIDE = 4
## CELL_NEIGHBOR_LEFT_SIDE = 8
## CELL_NEIGHBOR_TOP_SIDE = 12
## Keys are the possible sums of present connections
const SINGLE_CLOSED_BORDER_DIRECTION_ALTERNATIVE_TLE = {
	24: 1,
	20: 2,
	16: 3,
	12: 0
}
## This case has an +1 offset on 12 (for 12+0 != 8+4)
const TWO_ADJACENT_CONNECTIONS_ALTERNATIVE_TILE = {
	4: 0,
	12: 1,
	21: 2,
	13: 3
}
## Keys are the possible sums of present connections
const TWO_OPPOSITE_CONNECTIONS_ALTERNATIVE_TILE = {
	8: 1,
	16: 0
}
## Keys are the possible sums of present connections
const SINGLE_OPEN_BORDER_DIRECTION_ALTERNATIVE_TILE = {
	0: 0,
	4: 1,
	8: 2,
	12: 3
}

## Only public funcion, receives the cell being painted, and which neighboors cells are connected (don't have border)
## The caller should be responsible for calling each cell that needs to be reconsidered
func set_tile_borders(cell: Vector2i, connections: Array[TileSet.CellNeighbor]) -> void:
	if connections.size() >= 4:
		erase_cell(cell)
	else:
		var border_tile = _get_border_tile(connections)
		var alternative_tile = _get_alternative_cell(connections)
		set_cell(cell, SOURCE, border_tile, alternative_tile)


func _get_border_tile(connections: Array[TileSet.CellNeighbor]) -> Vector2i:
	if (connections.is_empty()):
		return Vector2i.ZERO
	elif (connections.size() == 1):
		return Vector2i(1, 0)
	elif (connections.size() == 2):
		if _connection_pair_is_adjacent(connections):
			return Vector2i(2, 0)
		else:
			return Vector2i(3, 0)
	else:
		##3 connections
		return Vector2i(4, 0)

func _get_alternative_cell(connections: Array[TileSet.CellNeighbor]) -> int:
	var connections_sum = connections.reduce(_reduce_sum, 0)
	if connections.size() == 1:
		return SINGLE_OPEN_BORDER_DIRECTION_ALTERNATIVE_TILE[connections_sum]
		
	elif connections.size() == 2:
		if _connection_pair_is_adjacent(connections):
			if (connections.has(TileSet.CELL_NEIGHBOR_TOP_SIDE)):
				connections_sum += 1
			return TWO_ADJACENT_CONNECTIONS_ALTERNATIVE_TILE[connections_sum]
		else:
			return TWO_OPPOSITE_CONNECTIONS_ALTERNATIVE_TILE[connections_sum]
	elif connections.size() == 3:
		return SINGLE_CLOSED_BORDER_DIRECTION_ALTERNATIVE_TLE[connections_sum]
	return 0

func _reduce_sum(accum, number):
	return accum + number

func _connection_pair_is_adjacent(connections: Array[TileSet.CellNeighbor]) -> bool:
	return abs(connections.front() - connections.back()) != 8
