extends Node

const USER_SETTINGS_PATH = "user://user_settings.cfg"
const DEFAULT_SETTINGS_PATH = "res://default_settings.cfg"

func _ready():
	_load_settings()

func _load_settings():
	## Load the pomodore settings to be saved in the State autoload.
	var dir : Directory = Directory.new()
	var settings_path : String
	if dir.file_exists(USER_SETTINGS_PATH):
		settings_path = USER_SETTINGS_PATH
	else:
		settings_path = DEFAULT_SETTINGS_PATH
		_create_user_settings()

	var config : ConfigFile = ConfigFile.new()
	var error : int = config.load(settings_path)
	if error == OK: # if not, something went wrong with the file loading.
		# POMODORE CONFIGURATION SETTINGS
		State.pomodore_work_time = config.get_value("pomodore", "work_time", State.pomodore_work_time)
		State.pomodore_pause_time = config.get_value("pomodore", "pause_time", State.pomodore_pause_time)

		print("Succesfully loaded and processed '{0}'.".format([settings_path]))
		return OK
	else:
		push_error("Failed to open '{0}', check file availability!".format([settings_path]))
		return error

func _create_user_settings():
	var dir : Directory = Directory.new()
# warning-ignore:return_value_discarded
	dir.copy(DEFAULT_SETTINGS_PATH, USER_SETTINGS_PATH)
