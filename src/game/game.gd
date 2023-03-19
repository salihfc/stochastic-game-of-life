extends Node2D
class_name Game
### SIGNAL ###
### ENUM ###

enum TileType {
	EMPTY = -1,
	WHITE = 0,
}

### CONST ###
### EXPORT ###

@export var WORLD_RECT_GROW : int = 16
@export var GRID_WIDTH : int = 10
@export var GRID_HEIGHT : int = 10
@export var STEP_DELAY : float = 1.0

@export var STEP_EVERY_FRAME : bool = false

### PUBLIC VAR ###
### PRIVATE VAR ###
var _age_tile_count : int = 6
var _running = false

var _world_rect : Rect2i
var _prob_dist : Dictionary = {
  0: 0.05,
  1: 0.183,
  2: 0.557,
  3: 1.0,
  4: 0.557,
  5: 0.183,
  6: 0.05,
  7: 0.01,
  8: 0.003
	# 0: 0.020,
	# 1: 0.073,
	# 2: 0.221,
	# 3: 0.398,
	# 4: 0.221,
	# 5: 0.073,
	# 6: 0.020,
	# 7: 0.004,
	# 8: 0.001
}

var _prob_dist_full : Dictionary = {
  0: 0.05,
  1: 0.183,
  2: 1.0,
  3: 1.0,
  4: 1.0,
  5: 0.183,
  6: 0.05,
  7: 0.01,
  8: 0.003
}


### ONREADY VAR ###

@onready var grid : TileMap = %Grid
@onready var clear_button : Button = %ClearButton
@onready var start_button : Button = %StartButton
@onready var pause_continue_button : Button = %PauseContinueButton


### VIRTUAL FUNCTIONS (_init ...) ###

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	pause_continue_button.pressed.connect(_on_pause_continue_button_pressed)

	_world_rect = Rect2i().grow(WORLD_RECT_GROW)

	if not STEP_EVERY_FRAME:
		assert(STEP_DELAY * 60 > 1, "STEP_DELAY is too small")
		create_tween().set_loops(-1).tween_callback(_step).set_delay(STEP_DELAY)


func _process(_delta: float) -> void:
	if STEP_EVERY_FRAME and _running:
		_step()


### PUBLIC FUNCTIONS ###
### PRIVATE FUNCTIONS ###

func _init_random() -> void:
	var half_width : int = GRID_WIDTH >> 1
	var half_height : int = GRID_HEIGHT >> 1

	for x in range(-half_width, half_width + 1):
		for y in range(-half_height, half_height + 1):
			_set_cell(Vector2i(x, y), (randi() % 2) - 1)


func _clear() -> void:
	grid.clear()


func _step() -> void:
	if not _running:
		return

	var size_rect = grid.get_used_rect()
	## expand the rect to include the neighbors
	size_rect = size_rect.grow(1)
	## make sure the rect is inside the world
	size_rect = size_rect.intersection(_world_rect)

	# print("size_rect: %s\ncells: %s" % [size_rect, size_rect.get_area()])

	for x in range(size_rect.position.x, size_rect.position.x + size_rect.size.x):
		for y in range(size_rect.position.y, size_rect.position.y + size_rect.size.y):
			var cell_value : TileType = _get_cell(Vector2i(x, y))
			var white_neighbour_count : int = _get_neighbour_count_with(Vector2i(x, y), Vector2i(1, 1), TileType.WHITE)

			var next_value : TileType = _calc_cell_next_state(cell_value, white_neighbour_count)
			_set_cell(Vector2i(x, y), next_value)


func _calc_cell_next_state(cell_value : TileType, white_neighbour_count : int) -> TileType:
	match cell_value:
		TileType.EMPTY:
			## rather than [0, 0, 0, 1, 0, 0, 0, 0, 0] distribution
			## use gaussian distribution centered around index 3
			assert(_prob_dist.has(white_neighbour_count), "Invalid white_neighbour_count: %s" % white_neighbour_count)
			var birth = UTILS.check(_prob_dist[white_neighbour_count])
			if birth:
				return TileType.WHITE
			else:
				return TileType.EMPTY

		_:
			assert(_prob_dist_full.has(white_neighbour_count), "Invalid white_neighbour_count: %s" % white_neighbour_count)
			var alive = UTILS.check(_prob_dist_full[white_neighbour_count])

			## give a chance to survive
			alive = alive or UTILS.check(_prob_dist_full[white_neighbour_count])

			if alive:
				var next_value = min(_next_cell_value(cell_value), _age_tile_count - 1) as TileType
				return next_value
			else:
				return TileType.EMPTY


func _next_cell_value(cell_value : TileType) -> int:
	return cell_value + 1

func _get_neighbour_count_with(pos : Vector2i, kernel_size : Vector2i, tile_type : TileType) -> int:
	var count : int = 0
	var x_begin : int = pos.x - kernel_size.x
	var x_end : int = pos.x + kernel_size.x
	var y_begin : int = pos.y - kernel_size.y
	var y_end : int = pos.y + kernel_size.y

	for x in range(x_begin, x_end + 1):
		for y in range(y_begin, y_end + 1):
			if x == pos.x and y == pos.y:
				continue
			var neighbour_pos : Vector2i = Vector2i(x, y)
			if _get_cell(neighbour_pos) == tile_type:
				count += 1

	return count


func _get_cell(pos : Vector2i) -> TileType:
	return grid.get_cell_source_id(0, pos) as TileType


func _set_cell(pos : Vector2i, value : TileType) -> void:
	grid.set_cell(0, pos, value, Vector2i(0, 0))


func _set_running(running : bool) -> void:
	_running = running
	if _running:
		pause_continue_button.text = "pause"
	else:
		pause_continue_button.text = "continue"

### SIGNAL RESPONSES ###


func _on_start_button_pressed() -> void:
	_set_running(true)


func _on_clear_button_pressed() -> void:
	_clear()
	_set_running(false)


func _on_pause_continue_button_pressed() -> void:
	_set_running(not _running)
