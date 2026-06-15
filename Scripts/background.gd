extends Node2D

func _draw() -> void:
	var W := get_viewport_rect().size.x
	var H := get_viewport_rect().size.y

	# Sky
	draw_rect(Rect2(0, 0, W, H), Color("87CEEB"))

	# Sun
	draw_circle(Vector2(W * 0.85, H * 0.12), H * 0.07, Color("FFE135"))

	# Back hills (lighter green)
	var back_hills := PackedVector2Array([
		Vector2(0, H * 0.72),
		Vector2(W * 0.12, H * 0.5),
		Vector2(W * 0.28, H * 0.64),
		Vector2(W * 0.45, H * 0.44),
		Vector2(W * 0.62, H * 0.58),
		Vector2(W * 0.78, H * 0.46),
		Vector2(W * 0.9, H * 0.6),
		Vector2(W, H * 0.52),
		Vector2(W, H),
		Vector2(0, H),
	])
	draw_polygon(back_hills, [Color("9ACD6E")])

	# Front ground (vivid green)
	var ground := PackedVector2Array([
		Vector2(0, H * 0.68),
		Vector2(W * 0.18, H * 0.62),
		Vector2(W * 0.38, H * 0.7),
		Vector2(W * 0.58, H * 0.6),
		Vector2(W * 0.76, H * 0.67),
		Vector2(W, H * 0.62),
		Vector2(W, H),
		Vector2(0, H),
	])
	draw_polygon(ground, [Color("5DBB3F")])

	# Clouds
	_draw_cloud(Vector2(W * 0.14, H * 0.14), H * 0.06)
	_draw_cloud(Vector2(W * 0.52, H * 0.09), H * 0.075)
	_draw_cloud(Vector2(W * 0.73, H * 0.17), H * 0.055)

	# Flowers
	_draw_flower(Vector2(W * 0.08,  H * 0.8),  H * 0.022)
	_draw_flower(Vector2(W * 0.25,  H * 0.85), H * 0.018)
	_draw_flower(Vector2(W * 0.55,  H * 0.78), H * 0.024)
	_draw_flower(Vector2(W * 0.78,  H * 0.83), H * 0.02)
	_draw_flower(Vector2(W * 0.92,  H * 0.79), H * 0.021)


func _draw_cloud(pos: Vector2, size: float) -> void:
	var c := Color.WHITE
	draw_circle(pos, size, c)
	draw_circle(pos + Vector2(-size * 0.65, size * 0.2), size * 0.72, c)
	draw_circle(pos + Vector2( size * 0.65, size * 0.2), size * 0.72, c)
	draw_circle(pos + Vector2( size * 0.32, size * 0.1), size * 0.82, c)
	draw_circle(pos + Vector2(-size * 0.32, size * 0.1), size * 0.78, c)
	draw_rect(Rect2(pos.x - size * 1.35, pos.y, size * 2.7, size * 0.55), c)


func _draw_flower(pos: Vector2, size: float) -> void:
	# Stem
	draw_line(pos, pos + Vector2(0, size * 3.5), Color("3A7D1E"), maxf(1.5, size * 0.25))
	# Petals
	for i in 5:
		var angle := i * TAU / 5.0 - PI / 2.0
		var petal := pos + Vector2(cos(angle), sin(angle)) * size * 1.6
		draw_circle(petal, size, Color("FFD700"))
	# Center
	draw_circle(pos, size * 1.1, Color("FF7A00"))
