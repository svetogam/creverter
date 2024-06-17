extends Area2D

signal changed

var fill_color := Color(randf(), randf(), randf())


func _draw() -> void:
	var center := Vector2(0, 0)
	var radius := 25.0
	var outline_width := 2.0
	var outline_color := Color(0.0, 0.0, 0.0)
	draw_circle(center, radius, fill_color)
	draw_arc(center, radius, 0, 2 * PI, 100, outline_color, outline_width)


func recolor() -> void:
	fill_color = Color(randf(), randf(), randf())
	queue_redraw()


func save_state() -> Dictionary:
	return {
		"position": position,
		"color": fill_color,
	}


func load_state(state: Dictionary) -> void:
	position = state.position
	fill_color = state.color
	queue_redraw()
