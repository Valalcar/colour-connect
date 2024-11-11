class_name SectionHUD
extends Control

@onready var stats_container: VBoxContainer = $PanelContainer/MarginContainer/StatsVBoxContainer

func _ready() -> void:
	SignalHub.section_stats_recalculated.connect(_show_section_stats)

func reset() -> void:
	_clear_stats()
	var empty_label = Label.new()
	empty_label.text = "- EMPTY -"
	stats_container.add_child(empty_label)

func _clear_stats() -> void:
	for stat in stats_container.get_children():
		stats_container.remove_child(stat)

func _show_section_stats(stats: Array[SectionColorGroup]) -> void:
	_clear_stats()

	var labels: Array[Label] = []
	for group in stats:
		var stat_label = Label.new()
		stat_label.text = group.color + " - " + str(group.cells_count)
		stats_container.add_child(stat_label)
