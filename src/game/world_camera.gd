extends Camera2D
class_name WorldCamera

### SIGNAL ###
### ENUM ###
### CONST ###
### EXPORT ###

@export var camera_speed = 200
@export var zoom_speed = 0.1

### PUBLIC VAR ###
### PRIVATE VAR ###
### @onready VAR ###
### VIRTUAL FUNCTIONS (_init ...) ###
### PUBLIC FUNCTIONS ###
### PRIVATE FUNCTIONS ###
var _target_zoom : float = 1

### SIGNAL RESPONSES ###

func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			## zoom out
			_target_zoom /= 1 + zoom_speed * event.factor
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			## zoom in
			_target_zoom *= 1 + zoom_speed * event.factor


func _process(delta):
	## zoom
	if not is_equal_approx(_target_zoom, zoom.x):
		zoom = Vector2.ONE * lerp(zoom.x, _target_zoom, 0.1)

	# movement controls
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		position.x += camera_speed * delta
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		position.x -= camera_speed * delta
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_down"):
		position.y += camera_speed * delta
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_up"):
		position.y -= camera_speed * delta