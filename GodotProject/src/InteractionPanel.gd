extends PanelContainer

onready var _option_container : VBoxContainer = $OptionContainer
onready var _quack_count : VBoxContainer = $QuackCount
onready var _quit_helper : VBoxContainer = $QuitHelper
onready var _pomodore_work : VBoxContainer = $PomodoreWork
onready var _pomodore_pause : VBoxContainer = $PomodorePause
onready var _pomodore_start : VBoxContainer = $PomodoreStart

onready var _options : VBoxContainer = _option_container.get_node("Options")

onready var _pomodore_link : LinkButton = _options.get_node("PomodoreLink")
onready var _count_link : LinkButton = _options.get_node("CountLink")
onready var _quit_link : LinkButton = _options.get_node("QuitLink")

onready var _pomodore_start_label : Label = _pomodore_start.get_node("Label")

onready var _cancel_work_link : LinkButton = _pomodore_work.get_node("LinkButton")
onready var _work_time_label : Label = _pomodore_work.get_node("Label")

onready var _cancel_pause_link : LinkButton = _pomodore_pause.get_node("LinkButton")
onready var _pause_time_label : Label = _pomodore_pause.get_node("Label")

onready var _quack_count_label : Label = _quack_count.get_node("Label")

onready var _fade_timer : Timer = $FadeTimer
onready var _pomodore_timer : Timer = $PomodoreTimer

const FADE_TIME : float = 2.0

enum LINK_TYPE {POMODORE, COUNT, QUIT, CANCEL}

func _ready():
	visible = false
	hide_all()
	_option_container.visible = true

	_fade_timer.wait_time = FADE_TIME

	_pomodore_start_label.text = "A Pomodore cycle of {0} minutes {1} seconds has started...\n".format(get_minutes_and_seconds(State.pomodore_work_time*60))
	_pomodore_start_label.text += "I will hide now and warn you when to take a break!"

# warning-ignore:return_value_discarded
	_pomodore_link.connect("pressed", self, "_on_link_button_pressed", [LINK_TYPE.POMODORE])
# warning-ignore:return_value_discarded
	_count_link.connect("pressed", self, "_on_link_button_pressed", [LINK_TYPE.COUNT])
# warning-ignore:return_value_discarded
	_quit_link.connect("pressed", self, "_on_link_button_pressed", [LINK_TYPE.QUIT])

# warning-ignore:return_value_discarded
	_cancel_work_link.connect("pressed", self, "_on_link_button_pressed", [LINK_TYPE.CANCEL])
# warning-ignore:return_value_discarded
	_cancel_pause_link.connect("pressed", self, "_on_link_button_pressed", [LINK_TYPE.CANCEL])

# warning-ignore:return_value_discarded
	State.connect("quack_count_changed", self, "update_state_variable", [State.STATE_VARIABLE.QUACK_COUNT])
# warning-ignore:return_value_discarded
	State.connect("pomodore_work_time_changed", self, "update_state_variable", [State.STATE_VARIABLE.POMODORE_TIME_REMAINING])
# warning-ignore:return_value_discarded
	State.connect("pomodore_pause_time_changed", self, "update_state_variable", [State.STATE_VARIABLE.POMODORE_TIME_REMAINING])

# warning-ignore:return_value_discarded
	_fade_timer.connect("timeout", self, "on_fade_timer_timeout")
# warning-ignore:return_value_discarded
	_pomodore_timer.connect("timeout", self, "on_pomodore_timer_timeout")

func hide_all():
	for child in get_children():
		if("visible" in child):
			child.visible = false

func toggle_visibility():
	if visible:
		visible = false
		State.current_state = State.INTERACTION_STATE.IDLE
		update_state_conditions()
	else:
		visible = true

func on_fade_timer_timeout():
	match State.current_state:
		State.INTERACTION_STATE.POMODORE_TRANSITION:
			State.current_state = State.INTERACTION_STATE.POMODORE_WORK
		State.INTERACTION_STATE.QUIT_TRANSITION:
			State.current_state = State.INTERACTION_STATE.QUIT
	update_state_conditions()

func on_pomodore_timer_timeout():
	match State.current_state:
		State.INTERACTION_STATE.POMODORE_WORK:
			State.current_state = State.INTERACTION_STATE.POMODORE_PAUSE
		State.INTERACTION_STATE.POMODORE_PAUSE:
			State.current_state = State.INTERACTION_STATE.POMODORE_TRANSITION
	update_state_conditions()

func _on_link_button_pressed(link_type : int):
	match link_type:
		LINK_TYPE.POMODORE:
			State.current_state = State.INTERACTION_STATE.POMODORE_TRANSITION
		LINK_TYPE.COUNT:
			State.current_state = State.INTERACTION_STATE.QUACK_COUNT
		LINK_TYPE.QUIT:
			State.current_state = State.INTERACTION_STATE.QUIT_TRANSITION
		LINK_TYPE.CANCEL:
			State.current_state = State.INTERACTION_STATE.IDLE
	update_state_conditions()

func update_state_conditions():
	hide_all()
	print("updating state")
	State.has_state_been_updated = true
	match State.current_state:
		State.INTERACTION_STATE.POMODORE_TRANSITION:
			_pomodore_start.visible = true
			_fade_timer.start()
		State.INTERACTION_STATE.QUACK_COUNT:
			_quack_count.visible = true
		State.INTERACTION_STATE.QUIT_TRANSITION:
			_quit_helper.visible = true
			_fade_timer.start()
		State.INTERACTION_STATE.IDLE:
			_option_container.visible = true
		State.INTERACTION_STATE.POMODORE_WORK:
			print("Starting Pomodore work cycle")
			_pomodore_work.visible = true
			OS.window_minimized = true
			OS.set_window_always_on_top(false)
			State.is_currently_working = true
			State.is_in_pomodore = true
			_pomodore_timer.wait_time = State.pomodore_work_time*60
			_pomodore_timer.start()
		State.INTERACTION_STATE.POMODORE_PAUSE:
			print("Starting Pomodore pause cycle")
			_pomodore_pause.visible = true
			OS.window_minimized = false
			OS.set_window_always_on_top(true)
			State.is_currently_working = false
			State.is_in_pomodore = true
			_pomodore_timer.wait_time = State.pomodore_pause_time*60
			_pomodore_timer.start()
		State.INTERACTION_STATE.POMODORE_TRANSITION:
			_pomodore_start.visible = true
			_fade_timer.start()
		State.INTERACTION_STATE.QUIT:
			get_tree().quit()

func _process(_delta):
	if State.is_in_pomodore:
		State.pomodore_time_remaining = _pomodore_timer.time_left

func update_state_variable(variable_name : int):
	match variable_name:
		State.STATE_VARIABLE.QUACK_COUNT:
			_quack_count_label.text = "You have QuAcKeD me {0} times!".format([State.quack_count])
		State.STATE_VARIABLE.POMODORE_TIME_REMAINING:
			if not State.is_currently_working:
				_pause_time_label.text = "Take a break!!!\n"
				_pause_time_label.text += "Current break time is {0} minutes {1} seconds".format(get_minutes_and_seconds(State.pomodore_time_remaining))
			else:
				_work_time_label.text = "Currently there's {0} minutes {1} seconds remaining\n".format(get_minutes_and_seconds(State.pomodore_time_remaining))
				_work_time_label.text += "until your break!"

func get_minutes_and_seconds(time : float):
	return [floor(time/60), floor(int(ceil(time)) % 60)]
