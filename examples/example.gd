extends Node

const MAX_ITEMS: int = 20
var reverter := CReverter.new()


func _ready() -> void:
	reverter.history.max_size = MAX_ITEMS
	$Field.setup(reverter)
	$ControlBoard.setup(reverter)
