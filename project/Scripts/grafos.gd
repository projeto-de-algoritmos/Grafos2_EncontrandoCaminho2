extends Node2D

var graph_dict = {}

func initiate(x):
	graph_dict = x
	
func nodes():
	return graph_dict.keys()
	
func get_neighbors(node):
	return graph_dict[node].keys()
	
func add_node(node):
	if not node in graph_dict:
		graph_dict[node] = {}

func add_neighbor(node, neighbor, attr):
	graph_dict[node][neighbor] = attr

func clear():
	graph_dict = {}
