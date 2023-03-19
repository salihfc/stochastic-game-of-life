@tool
extends Node

@export var console_logging := false
# masks
const _FLAG_PREFIX = "_log_flags/"
var _log_flag_data = {}

enum LOG_TYPE {
	INTERNAL	= 1 << 0,
	SIGNAL		= 1 << 1,
	AI			= 1 << 2,
	GAMEPLAY	= 1 << 3,
	VFX			= 1 << 4,
	SFX			= 1 << 5,
	INPUT		= 1 << 6,
	PHYSICS		= 1 << 7,

	COUNT		= 1 << 8,
}

func _get(property: StringName):
	return _log_flag_data.get(property)


func _set(property: StringName, value = false) -> bool:
	_log_flag_data[property] = value
	return true


func _get_property_list() -> Array:
	var props = []
	for type in LOG_TYPE.keys():
		props.append(
			{
				'name' : _FLAG_PREFIX + type,
				'type' : TYPE_BOOL,
			}
		)
	return props


func _get_log_flag(log_type : int) -> bool:
	var log_type_name = get_log_type_name(log_type)
	assert(log_type_name)
	var key = _FLAG_PREFIX + log_type_name
	return _log_flag_data[key]


func _set_log_flag(log_type : int, on) -> void:
	var log_type_name = get_log_type_name(log_type)
	assert(log_type_name)
	var key = _FLAG_PREFIX + log_type_name
	_log_flag_data[key] = on


func get_log_type_name(log_type, default = null):
	log_type = nearest_po2(log_type)
	log_type = min(log_type, 1 << 7)
	var _name = UTILS.get_enum_string_from_id(LOG_TYPE, _log_idx[log_type])
	if _name:
		return _name
	return default

# runtime mask
var runtime_mask = 0
var _log_idx = {}

func _ready() -> void:
	# Init & Precalc
	for i in UTILS.log2i(LOG_TYPE.COUNT) + 1:
		var log_type = 1 << i
		_log_idx[log_type] = i
		if _get_log_flag(log_type) == null:
			_set_log_flag(log_type, false)

	# Calculate runtime mask
	for idx in _log_idx[LOG_TYPE.COUNT] + 1:
		var log_flag = _get_log_flag(1 << idx)
		runtime_mask += int(log_flag) * (1 << idx)


	pr(LOG_TYPE.INTERNAL, "READY [log_mask:%s {%s}]" % [runtime_mask, _decomposed_mask()], "LOG")


func pr(log_mask: int, log_msg, caller:String = "") -> void:
	if not OS.is_debug_build() or (log_mask & runtime_mask == 0):
		return

	if not console_logging:
		return

	var msg = str(log_msg) + " -- \t\t\t\t[%s]"%caller
	msg = get_log_type_name(log_mask, "UNK") + " -- " + msg

	if console_logging:
		print(msg)


func err(err_msg, caller:String = "") -> void:
	var msg = str(err_msg) + ("\t\t\t\t[%s]"%caller)
	msg = "ERROR" + " -- " + msg
	push_error(msg)


func _decomposed_mask() -> String:
	var string = ""
	for idx in _log_idx[LOG_TYPE.COUNT] + 1:
		var log_flag = _get_log_flag(1 << idx)
		if log_flag:
			string += get_log_type_name(1 << idx) + " | "
	return string
