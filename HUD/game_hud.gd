extends CanvasLayer

@onready var section_hud: SectionHUD = $SectionHUD
@onready var board_hud: Control = $BoardHUD

func _ready() -> void:
	SignalHub.section_opened.connect(show_section_hud)
	SignalHub.section_closed.connect(show_board_hud)

func show_section_hud() -> void:
	section_hud.reset()
	section_hud.show()

func show_board_hud() -> void:
	section_hud.hide()
