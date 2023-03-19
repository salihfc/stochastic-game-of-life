@tool
extends Node

# Internal Logging
func _ready() -> void:
	LOG.pr(LOG.LOG_TYPE.INTERNAL, "READY", "UTILS")


## Node Manipulations
func transfer_children(from : Node, to : Node, children : Array = []) -> void:

	# Warning: Smelly!
	# Setup Defaul call
	if children.size() == 0:
		children = from.get_children()

	for ch in children:
		assert(ch.get_parent() == from)
		from.remove_child(ch)
		to.add_child(ch)


func clear_children(node : Node) -> void:
	var children = node.get_children()
	for child in children:
		node.remove_child(child)
		child.queue_free()


func get_parents(nodes : Array) -> Array:
	var parents = []
	for node in nodes:
		parents.append(node.get_parent())
	return parents


# pause_node: for debugging purposes
# TODO: Either implement mask based PAUSE system or Find a plugin that does it
func pause_node(node : Node, active = false) -> void:
	LOG.pr(LOG.LOG_TYPE.INTERNAL, "Pausing (%s) [%s]" % [node, active])
	Engine.time_scale = 1.0 if active else 0.0


## Object Manipulations

func get_owners(objects : Array) -> Array:
	var owners = []
	for obj in objects:
		owners.append(obj.get_owner())
	return owners

#	Expressions

func eval(expression_string, param_names, param_values):
	var expression = Expression.new()
	expression.parse(expression_string, param_names)
	var result = expression.execute(param_values)
	if result:
		return result
	return -1


func any(bool_array : Array) -> bool:
	for boolean in bool_array:
		if boolean:
			return true
	return false


func all(bool_array : Array) -> bool:
	for boolean in bool_array:
		if boolean == false:
			return false
	return true


#	Math


# Algebra
func clamp01(value):
	return clamp(value, 0.0, 1.0)

var inverse_log2 = 1.0 / log(2) # Precalc this value
func log2(x) -> float:
	return log(x) * inverse_log2

func log2i(x) -> int:
	return int(log2(x) + 0.0001)


# Linear Alg
func angle_to_vec2(theta) -> Vector2:
	return Vector2(cos(theta), sin(theta)).normalized()


func random_unit_vec2() -> Vector2:
	var theta = randf_range(0, 2 * PI)
	return angle_to_vec2(theta)


#	Random [Can be turned into a singleton if different distributions and prng is required]

func gauss_random(min_v : float, max_v : float) -> float:
	return randf_range(sqrt(min_v), sqrt(max_v)) * randf_range(sqrt(min_v), sqrt(max_v))



func check(p : float) -> bool:
	return randf() <= p


func get_random_subset(_set : Array, ct : int) -> Array:
	_set.shuffle()
	return _set.slice(0, ct - 1)


func get_random_from(_set : Array):
	return get_random_subset(_set, 1)[0]



#	2D-Geo


func get_closest_node(node : Node2D, other_nodes : Array):
	if node in other_nodes:
		other_nodes.erase(node)

	var closest = null
	var min_dist = INF
	for other_node in other_nodes:
		var dist = node.global_position.distance_to(other_node.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = other_node
	return closest



#	Array

func flatten_array(arr : Array):
	var new_arr = []
	for item in arr:
		if item is Array:
			new_arr.append_array(flatten_array(item))
		new_arr.append(item)
	return new_arr



#	Enums

func get_enum_string_from_id(enum_ref, id) -> String:
	assert(enum_ref)
	assert(enum_ref.keys().size() > id)
	return enum_ref.keys()[id]


func get_enum_hint_string(enum_ref) -> String:
	var arr = enum_ref.keys()
	var string = ""
	for idx in arr.size():
		var item = arr[idx]
		string += str(item)
		if idx+1 != arr.size():
			string += ','
	return string


func get_enum_strings_array(enum_ref) -> Array:
	var arr = enum_ref.keys() as Array
	if "COUNT" in arr:
		arr.erase("COUNT")
	return arr



#	Data-transforms


func vec2_to_int_arr(vec2 : Vector2) -> Array:
	return [int(vec2.x), int(vec2.y)]


func pretty_print(dict : Dictionary) -> void:
	print(JSON.new().stringfy(dict, "\t"))


func pretty_dict(dict : Dictionary) -> String:
	return JSON.new().stringfy(dict, "\t")


func wrap_str(string, begin = "[", end = "]") -> String:
	return begin + string + end


func extract_path_filename(path : String) -> String:
	var index = path.rfind('/')
	return path.right(index + 1)
