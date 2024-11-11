class_name BoardHUD
extends Control

@onready var turn_number_label: Label = $PanelContainer/Button/MarginContainer/HBoxContainer/TurnNumberLabel

func _ready() -> void:
	SignalHub.turn_changed.connect(refresh_turn_counter)
	refresh_turn_counter(TurnHandler.current_turn)


func refresh_turn_counter(turn_count: int) -> void:
	turn_number_label.text = str(turn_count)

func _on_button_button_down() -> void:
	SignalHub.next_turn.emit()
