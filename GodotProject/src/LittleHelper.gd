extends Node2D

var _is_mouse_pressed : bool = false
var _reference_mouse_position : Vector2 = Vector2.ZERO
var _mouse_offset : Vector2 = Vector2.ZERO
var _is_message_showing : bool = false
var _is_currently_blinking : bool = false

#var _icon_texture : Texture = preload("res://graphics/background.png")

var can_blink : bool = true
var can_show_message : bool = true
var can_play_sound : bool = true

var _possible_messages : Array = [
	"Tell me everything!", 
	"I want to be your friend :)", 
	"I <3 you!",
	"Godot sure is fun ;)",
	"Here is to the best game engine!",
	"Waiting for Godot 4.0...",
	"You can crack the code :D",
	"Don't give up!",
	"I believe in you <3",
	"If you get stuck, I'll help you!",
	"There's nothing you can't do!"
]

var _possible_names : Array = [
	"Faithful Lil' Helper'",
	"Godot-kun",
	"Bug Fixer 9000"
]

const MIN_MESSAGE_TIMEOUT : float = 5.0
const MAX_MESSAGE_TIMEOUT : float = 10.0
const MIN_BLINK_TIMEOUT : float = 4.0
const MAX_BLINK_TIMEOUT : float = 6.0
const MESSAGE_SHOW_TIME : float = 4.0
const BLINK_TIME : float = 1.0

const BLINK_FPS : float = 5.0

const POMODORE_TIME : float = 25.0
const POMODORE_BREAK_TIME : float = 5.0

onready var _vbox_container : VBoxContainer = $VBoxContainer
onready var _audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer
onready var _blink_timer : Timer = $BlinkTimer
onready var _message_timer : Timer = $MessageTimer

onready var _helper_button : TextureButton = _vbox_container.get_node("HelperButton")
onready var _message_label : Label = _vbox_container.get_node("MessageLabel")

onready var _animations : Node2D = _helper_button.get_node("Animations")
onready var _eyes : AnimatedSprite = _helper_button.get_node("Eyes")

onready var _mouth_animation_player : AnimationPlayer = _animations.get_node("MouthAP")

func _ready():
	randomize()
	_message_label.visible = false
	
	OS.window_per_pixel_transparency_enabled = true
	get_tree().get_root().set_transparent_background(true)

# warning-ignore:return_value_discarded
	_helper_button.connect("pressed", self, "_on_button_pressed")
# warning-ignore:return_value_discarded
	_message_timer.connect("timeout", self, "_on_message_timer_timeout")
# warning-ignore:return_value_discarded
	_blink_timer.connect("timeout", self, "_on_blink_timer_timeout")

	if can_show_message:
		_message_timer.wait_time = rand_range(MIN_MESSAGE_TIMEOUT, MAX_MESSAGE_TIMEOUT)
		_message_timer.start()

	if can_blink:
		_blink_timer.wait_time = rand_range(MIN_BLINK_TIMEOUT, MAX_BLINK_TIMEOUT)
		_blink_timer.start()

func _input(event : InputEvent):
	if event.is_action_pressed("LMB"):
		_is_mouse_pressed = true
		_reference_mouse_position = get_global_mouse_position()
		_mouse_offset = _reference_mouse_position - (_vbox_container.rect_position + _vbox_container.rect_size/2.0)
	if event.is_action_released("LMB"):
		_is_mouse_pressed = false

func _process(_delta : float):
	if _is_mouse_pressed and _helper_button.is_mouse_inside:
		var mouse_position : Vector2 = get_global_mouse_position()
		mouse_position -= _mouse_offset
#		print(_mouse_offset)
#		print(_vbox_container.rect_position.y)
		_vbox_container.rect_position = mouse_position - _vbox_container.rect_size/2.0
#		print(_vbox_container.rect_position.y)

func _on_button_pressed():
	if can_play_sound:
		_audio_stream_player.playing = true

func _on_message_timer_timeout():
	if not _is_message_showing:
		_is_message_showing = true
		_message_label.text = "{0}      ".format([_possible_messages[randi() % _possible_messages.size()]])
		_message_label.visible = true
		_message_timer.wait_time = MESSAGE_SHOW_TIME
	else:
		_is_message_showing = false
		_message_label.visible = false
		_message_timer.wait_time = rand_range(MIN_MESSAGE_TIMEOUT, MAX_MESSAGE_TIMEOUT)
	_message_timer.start()

func _on_blink_timer_timeout():
	if not _is_currently_blinking:
		print("blinking!")
		_is_currently_blinking = true
		_eyes.play("blink")
		_blink_timer.wait_time = BLINK_TIME
	else:
		_is_currently_blinking = false
		_blink_timer.wait_time = rand_range(MIN_BLINK_TIMEOUT, MAX_BLINK_TIMEOUT)
	_blink_timer.start()
