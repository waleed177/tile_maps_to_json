# This file belongs to the tile_map_to_json plugin
#
# MIT License
# 
# Copyright (c) 2021 waleed177
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
tool
extends Node2D

export(Vector2) var size = Vector2(5, 5)
export(String) var path = ""
export(bool) var prepend_tileset_id = false
export(Vector2) var grid_size = Vector2(64, 64) 
export(Array, Resource) var tilesets: Array
export(Vector2) var layer_offset: Vector2
export(bool) var draw_highlight: bool = true
export(int) var highlight_height: int = 0
export(float) var highlight_width: float = 12
export(Color) var highlight_color: Color = Color.red
export(bool) var auto_positioning: bool = true

func _process(delta):
	if auto_positioning:
		var i = Vector2(0, 0)
		for child in get_children():
			if child is TileMap:
				child.position = i
				i += layer_offset
	update()

func _draw():
	if draw_highlight:
		draw_rect(
			Rect2(
				-highlight_width/2,
				layer_offset.y * highlight_height -highlight_width/2,
				grid_size.x*size.x + highlight_width/2,
				grid_size.y*size.y + highlight_width/2
			),
			highlight_color,
			false,
			highlight_width
		)
	
