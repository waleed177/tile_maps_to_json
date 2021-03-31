tool
extends EditorPlugin

const TilemapInfo = preload("./tilemap_info.gd")

func _enter_tree():
	add_custom_type("TileMapInfo", "Node2D", preload("./tilemap_info.gd"), null) 
	connect("resource_saved", self, "_on_resource_saved")


func _exit_tree():
	remove_custom_type("TileMapInfo")



func tile_map_to_ids(tilemap: TileMap, size: Vector2):
	var ids = []
	for y in size.y:
		for x in size.x:
			var tile_id = tilemap.get_cell(x, y)
			var tile_name = tilemap.tile_set.tile_get_name(tile_id) if tile_id >= 0 else null
			ids.append(tile_name)
	return ids

func _on_resource_saved(resource):
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene is TilemapInfo:
		return false
	
	var tilemap_size = scene.size
	
	var layers = []
	var tilesets = []
	
	for node in scene.get_children():
		if node is TileMap:
			layers.append(tile_map_to_ids(node, tilemap_size))
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
							obj[property.name] = prefab.get(property.name)
					current_layer[index] = obj
				else:
					print("WARNING! A prefab (" + prefab.name + " in " + node.name + ") was not placed due to it overlapping a tile!")
	
	var save = {
		size = [tilemap_size.x, tilemap_size.y],
		layers = layers,
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
	file.open(save_path, File.WRITE)
	file.store_string(JSON.print(save))
	file.close()
	print("Saved Tilemap at " + save_path)
