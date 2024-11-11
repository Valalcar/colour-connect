extends Node

## SCENE CHANGE
signal section_opened
signal section_closed

## TURN HANDLING
signal next_turn()
signal turn_changed(turn_number: int)

## SECTION EMMITED ##
signal section_stats_recalculated(stats: Array[SectionColorGroup])
