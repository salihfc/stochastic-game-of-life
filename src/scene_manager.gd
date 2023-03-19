extends CanvasLayer
class_name SceneManager

### SIGNAL ###
### ENUM ###
enum SCENE {
	GAME,

	COUNT,
}

const SCENES = {
	SCENE.GAME : preload("res://src/game/game.tscn"),
}
const PREV_SCENE = {
#	SCENE.GAME : SCENE.MAIN_MENU,
}


### CONST ###
const DEFAULT_FOREGROUND_COLOR = Color("0c0d1d")
const FULL_TRANSPARENT = Color(0.0, 0.0, 0.0, 0.0)
const FADE_MIN_DELAY = 0.3
const RECOVERY_MIN_DELAY = 0.5

@export var STARTING_SCENE := SCENE.GAME
### EXPORT ###
@export var mouse_normal_cursor : Texture
@export var mouse_pressed_cursor : Texture

### PUBLIC VAR ###
### PRIVATE VAR ###
var _current_scene = STARTING_SCENE
var _loading = false

### @onready VAR ###
@onready var foreground = $FadeRectLayer/Control/Foreground as ColorRect
@onready var sceneSlot = $CurrentSceneSlot as Control
@onready var dumpSlot = $DumpSlot as Control

### VIRTUAL FUNCTIONS (_init ...) ###
func _unhandled_key_input(event : InputEvent) -> void:

	var key_event = event as InputEventKey

	if key_event.pressed:
		match key_event.keycode:
			KEY_ESCAPE:
				if _current_scene in PREV_SCENE:
					change_scene(PREV_SCENE[_current_scene])
				else:
					LOG.pr(LOG.LOG_TYPE.INTERNAL, "Exiting..")
					get_tree().quit()


func _ready() -> void:
	randomize()
	LOG.pr(LOG.LOG_TYPE.INTERNAL, "READY", "SCENE_MANAGER")
	set_foreground_color(DEFAULT_FOREGROUND_COLOR)

	change_scene(STARTING_SCENE)


### PUBLIC FUNCTIONS ###
func is_loading():
	return _loading


func scene_loaded():
	_loading = false
	fade_in()


func set_foreground_color(new_color : Color) -> void:
	foreground.color = new_color


func change_scene(scene_id) -> void:
	_loading = true
	fade_out(scene_id)


func fade_out(scene_id):
	fade(1.0, FADE_MIN_DELAY)
	create_tween().tween_callback(add_scene.bind(scene_id)).set_delay(FADE_MIN_DELAY)


func add_scene(scene_id):
	if sceneSlot.get_child_count():
		UTILS.transfer_children(sceneSlot, dumpSlot)
		UTILS.call_deferred("clear_children", dumpSlot)

	_current_scene = scene_id
	var scene = SCENES[(scene_id)].instantiate()
	sceneSlot.add_child(scene)


func fade_in():
	bind_ui_buttons()
	fade(0.0, RECOVERY_MIN_DELAY)


func fade(alpha, duration := 0.5) -> void:
	var to = foreground.color
	to.a = alpha
	create_tween().tween_property(foreground, "color", to, duration)


func bind_ui_buttons():
	var ui_buttons = get_tree().get_nodes_in_group("ui_button")
	LOG.pr(LOG.LOG_TYPE.SFX, "UI_BUTTONS: %s" % [ui_buttons])


#	for button in ui_buttons:
#		SIGNAL.bind_bulk(button, AUDIO,
#			[
#				["mouse_entered", "play_ui_sfx", [AUDIO.UI_SFX.HOVER_BLIP]],
#				["pressed", "play_ui_sfx", [AUDIO.UI_SFX.PRESS_BLIP]],
#			],
#
#			true # check_before
#		)

	return self
