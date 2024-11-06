extends CanvasLayer

@onready var stats_container: VBoxContainer = $PanelContainer/StatsVBoxContainer
@onready var pieces_placement_layer: PiecesPlacementLayer = $"../PiecesPlacementLayer"

func _ready() -> void:
	if !pieces_placement_layer.ready:
		await pieces_placement_layer.read
	pieces_placement_layer.grouping_recalculated.connect(show_stats)

func show_stats(stats: Array[SectionColorGroup]) -> void:
	for stat in stats_container.get_children():
		stats_container.remove_child(stat)
		
	var labels: Array[Label] = []
	for group in stats:
		var stat_label = Label.new()
		stat_label.text = "   " + group.color + " - " + str(group.cells_count) + "   "
		stats_container.add_child(stat_label)
