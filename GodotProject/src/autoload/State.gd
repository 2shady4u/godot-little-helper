extends Node

enum INTERACTION_STATE {POMODORE_WORK, POMODORE_PAUSE, IDLE, QUACK_COUNT, POMODORE_TRANSITION, QUIT_TRANSITION, QUIT}
enum STATE_VARIABLE {QUACK_COUNT, POMODORE_TIME_REMAINING}

var quack_count : int = 0 setget set_quack_counter
var pomodore_time_remaining : float = 0 setget set_pomodore_time_remaining
var pomodore_work_time : float = 25
var pomodore_pause_time : float = 5

var is_currently_working : bool = true
var is_in_pomodore : bool = false
var current_state : int = INTERACTION_STATE.IDLE

signal quack_count_changed
signal pomodore_work_time_changed
signal pomodore_pause_time_changed

func _ready():
	pass # Replace with function body.

func set_quack_counter(new_count : int):
	quack_count = new_count
	emit_signal("quack_count_changed")

func set_pomodore_time_remaining(new_time : float):
	pomodore_time_remaining = new_time
	if is_currently_working:
		emit_signal("pomodore_work_time_changed")
	else:
		emit_signal("pomodore_pause_time_changed")
