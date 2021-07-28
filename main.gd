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
extends EditorPlugin

const TilemapInfo = preload("./tilemap_info.gd")

func _enter_tree():
	add_custom_type("TileMapInfo", "Node2D", preload("./tilemap_info.gd"), null) 
	connect("resource_saved", self, "_on_resource_saved")

func _exit_tree():
	remove_custom_type("TileMapInfo")

func tile_map_to_ids_and_damages(tilemap: TileMap, size: Vector2):
	var ids = []
	var damages = []
	for y in size.y:
		for x in size.x:
			var tile_id = tilemap.get_cell(x, y)
			var tile_name = tilemap.tile_set.tile_get_name(tile_id) if tile_id >= 0 else null
			if tile_name != null and tile_name.is_valid_integer():
				tile_name = int(tile_name)
			ids.append(tile_name)
			damages.append(0)
	return {
		ids = ids,
		damages = damages,
	}

func _on_resource_saved(resource):
	var scene = get_editor_interface().get_edited_scene_root() as TilemapInfo
	if not scene is TilemapInfo:
		return false
	
	var tilemap_size = scene.size
	
	var layers = []
	var tilesets = []
	var damages = []
	
	for node in scene.get_children():
		if node is TileMap:
			var tile_set_id = -99
			for i in len(scene.tilesets):
				var tileset = scene.tilesets[i]
				if tileset.resource_path == node.tile_set.resource_path:
					tile_set_id = -(i+1)
					break
			var damages_and_ids = tile_map_to_ids_and_damages(node, tilemap_size)
			
			if scene.prepend_tileset_id:
				layers.append([tile_set_id] + damages_and_ids.ids)
			else:
				layers.append(damages_and_ids.ids)
			
			damages.append(damages_and_ids.damages)
			
			var current_layer = layers[len(layers)-1]
			tilesets.append(node.tile_set.resource_path)
			for prefab in node.get_children():
				var pos: Vector2 = node.world_to_map(prefab.position)
				var index: int = pos.x + tilemap_size.x*pos.y
				
				if current_layer[index] == null:
					var obj = {
						"prefab": prefab.filename
					}
					for property in prefab.get_property_list():
						if property.usage == 8199:
							var value = prefab.get(property.name)
							if property.name == "prefab":
								print("WARNING! A prefab (" + prefab.name + " in " + node.name + ") has a property named prefab which conflicts with the built in property 'prefab', rename this property to something else.")
								continue
							if value != null and value != "":
								obj[property.name] = value
					current_layer[index] = obj
				else:
					print("WARNING! A prefab (" + prefab.name + " in " + node.name + ") was not placed due to it overlapping a tile!")
	
	layers.invert()
	tilesets.invert()
	
	var save = {
		size = [tilemap_size.x, tilemap_size.y],
		layers = layers,
		damages = damages,
		tilesets = tilesets,
	}
	
	var file = File.new()
	var current_directory = scene.filename.get_base_dir() 
	var save_path = ""
	if scene.path.begins_with("./"):
		save_path = current_directory + scene.path.substr(1)
	elif scene.path != "":
		save_path = scene.path
	else:
		save_path = scene.filename.get_basename() + ".json"
	var error = file.open(save_path, File.WRITE)
	if error != 0:
		print("Failed to save file " + save_path)
		return
	file.store_string(JSON.print(save))
	file.close()
	print("Saved Tilemap at " + save_path)
