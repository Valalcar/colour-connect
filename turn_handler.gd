extends Node

var current_turn : int = 1

func _ready() -> void:
	SignalHub.next_turn.connect(next_turn)
	
func next_turn() -> void:
	current_turn += 1
	SignalHub.turn_changed.emit(current_turn)
