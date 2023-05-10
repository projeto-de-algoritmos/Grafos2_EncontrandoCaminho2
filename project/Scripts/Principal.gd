extends Node2D

# Importando nós da cena principal 
onready var player = $Cat
onready var tilemap = $TileMap

# Declaração de variáveis 
enum {bfs, dfs, slow}
var mode = bfs
var speedmode = slow
var ortho = false
var map_graph = preload("res://Scenes/grafos.tscn").instance()
var tile_list
var start_node
var end_node
var running = false
var pop1

# Função para gerar o grafo
func build_graph():
	
	# limpa a instancia da cena 
	map_graph.clear()
	
	# Método get_used_cells retorna uma matriz de todas as células
	# que contêm um bloco do conjunto de blocos
	tile_list = tilemap.get_used_cells()
	for tile in tile_list:
		map_graph.add_node(tile)
	for tile in map_graph.graph_dict:
		
		var top = Vector2(tile.x, tile.y - 1)
		var bottom = Vector2(tile.x, tile.y + 1)
		var left = Vector2(tile.x - 1, tile.y)
		var right = Vector2(tile.x + 1, tile.y)
		if top in tile_list:
			map_graph.add_neighbor(tile, top, 1)
		if bottom in tile_list:
			map_graph.add_neighbor(tile, bottom, 1)
		if left in tile_list:
			map_graph.add_neighbor(tile, left, 1)
		if right in tile_list:
			map_graph.add_neighbor(tile, right, 1)
			
		var top_left = Vector2(tile.x - 1, tile.y - 1)
		var top_right = Vector2(tile.x + 1, tile.y - 1)
		var bottom_left = Vector2(tile.x - 1, tile.y + 1)
		var bottom_right = Vector2(tile.x + 1, tile.y + 1)
		if top_left in tile_list:
			map_graph.add_neighbor(tile, top_left, pow(2, 0.5))
		if top_right in tile_list:
			map_graph.add_neighbor(tile, top_right, pow(2, 0.5))
		if bottom_left in tile_list:
			map_graph.add_neighbor(tile, bottom_left, pow(2, 0.5))
		if bottom_right in tile_list:
			map_graph.add_neighbor(tile, bottom_right, pow(2, 0.5))

#Quando uma cena é carregada pela primeira vez, 
#esta função é chamada.
func _ready():
	build_graph()
	
	#Pega a posição inicial do player no mapa
	start_node = tilemap.world_to_map(player.global_position)

func _process(delta):
		
	# Quando o usuário clica em algum posição do mapa
	if Input.is_action_just_pressed("click") and not running:
		# Pega posição do mouse 
		end_node = tilemap.world_to_map(get_global_mouse_position())
		if tilemap.get_cellv(end_node) != -1 and end_node != start_node:
			for line in $Lines.get_children():
				line.queue_free()
			running = true
			if mode == bfs:
				bfs_dfs(start_node, end_node, true)
			elif mode == dfs:
				bfs_dfs(start_node, end_node, false)
	

func draw_line_nodes(start, end, color = Color(1, 1, 1, 0.7)):
	var line = Line2D.new()
	$Lines.add_child(line)
	line.set_width(2)
	line.set_default_color(color)
	line.add_point(Vector2(start.x * 32 + 16, start.y * 32 + 16))
	line.add_point(Vector2(end.x * 32 + 16, end.y * 32 + 16))
		
func bfs_dfs(start, end, is_bfs):
	var end_reached = false
	var visit_data = {}
	var parent_data = {}
	for node in map_graph.graph_dict:
		visit_data[node] = false
	visit_data[start_node] = true
	var rac = [start_node]
	
	var curr_node
	while rac: # enquanto a lista rac não está vazia
		if is_bfs:
			curr_node = rac.pop_front()
		else:
			curr_node = rac.pop_back()
		var neighbors = map_graph.get_neighbors(curr_node)
		neighbors.shuffle()
		for neighbor in neighbors:

			if neighbor == end_node: # se o vizinho for igual ao nó final.
				parent_data[neighbor] = curr_node # o pai do vizinho é definido como o nó atual
				draw_line_nodes(curr_node, neighbor) # desenha uma linha nó atual ao final
				rac = []
				curr_node = end_node 
				end_reached = true
				break
			elif visit_data[neighbor] == false:
				visit_data[neighbor] = true
				parent_data[neighbor] = curr_node
				rac.append(neighbor)
				draw_line_nodes(curr_node, neighbor)
				if speedmode == slow:
					yield(get_tree(), "idle_frame")
	if not end_reached:
		running = false
		return
	start_node = curr_node
	move_on_path(parent_data, start, curr_node)

func move_on_path(parent_dict, start_node, last_node):
	var rcurr_node = last_node
	var path_order = [last_node]
	while rcurr_node in parent_dict:
		path_order.append(parent_dict[rcurr_node])
		rcurr_node = parent_dict[rcurr_node]
	for i in range(len(path_order) - 1, -1, -1):
		var curr = path_order[i]
		var aux = player.global_position

		player.global_position = Vector2(curr.x *32 + 16 , curr.y *32 + 16)
		pop1 = player.global_position
		if i != 0: 
			draw_line_nodes(path_order[i], path_order[i-1], Color(0.627451, 0.12549, 0.941176, 1))
		yield(get_tree().create_timer(.13), "timeout")
		
	running = false


func _on_BFS_pressed():
	mode = bfs
func _on_DFS_pressed():
	mode = dfs


