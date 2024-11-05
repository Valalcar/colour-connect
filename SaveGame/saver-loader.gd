class_name SaverLoader
extends Node

const SAVE_PATH = "user://save_file.tres"

@onready var planet_board: PlanetBoard = %PlanetBoard

func _input(event: InputEvent) -> void:
	if event.is_action_released("num9"):
		save_game()
	elif event.is_action_released("num0"):
		load_game()

func save_game() -> void:
	var saved_game := SavedGame.new()

	saved_game.pattern = planet_board.get_pattern()
	saved_game.pattern_offset = planet_board.get_patern_offset()
	saved_game.sections = planet_board.sections
	
	ResourceSaver.save(saved_game, SAVE_PATH)

func load_game() -> void:
	var saved_game: SavedGame = ResourceLoader.load(SAVE_PATH) as SavedGame
	if saved_game == null:
		return

	planet_board.load_game(saved_game)
