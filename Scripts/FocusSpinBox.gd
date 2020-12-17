tool
class_name FocusSpinBox # An int-only SpinBox that allows the up/down buttons to gain focus.
extends Control

signal value_changed # passes value
signal focus_fully_exited # no binds
signal button_pressed # passes "up" or "down"

enum alignments {left, center, right, fill}
var value: int = 0
var last_valid_value: int = 0
export (int) var initial_value = 0 setget edit_initial_value
export var step: int = 1
export var round_to_step: bool = false
export var max_range: int = 100
export var min_range: int = 0
export var repeat_delay_secs: float = 0.6
export var repeat_interval_secs: float = 0.02
export (bool) var show_label = false setget edit_label_visible
export (String) var label_text = "" setget edit_label_text
export (alignments) var label_align = alignments.left setget edit_label_align

# forbidden LineEdit characters:

const common_inputs = [".", ",", "_", "+", "=", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
const symbol_inputs = ["<", ">", "!", "?", "@", "#", "$", "%", "&", "^", "/", "\\", "(", "{", "[", "|", ":", ";", "'", '"', ")", "}", "]", "~", "`"]
const accent_inputs = ["à", "è", "é", "â", "ê", "î", "ô", "û", "ç", "¨", "ä", "ë", "ü", "ï", "ö", "ÿ", "ŷ",]
# "
# editor functions

func edit_label_visible(_show_label):
	if Engine.is_editor_hint():
		show_label = not show_label 
		if show_label:
			$VBox/Label.visible = true
		else:
			$VBox/Label.visible = false

func edit_label_text(new_text:String):
	if Engine.is_editor_hint():
		label_text = new_text
		$VBox/Label.text = label_text

func edit_label_align(_label_align:int):
	if Engine.is_editor_hint():
		label_align = _label_align
		$VBox/Label.align = label_align

func edit_initial_value(_value:int):
	if Engine.is_editor_hint():
		initial_value = _value
		$VBox/HBox/LineEdit.text = _value as String

var repeat_delay_started: bool = false
var either_button_down: bool = false
var repeat_increment_value: int

onready var label = $VBox/Label
onready var up = $VBox/HBox/Buttons/Up
onready var down = $VBox/HBox/Buttons/Down
onready var repeat_delay = $VBox/HBox/Buttons/RepeatDelay
onready var repeat_interval = $VBox/HBox/Buttons/RepeatInterval
onready var line_edit = $VBox/HBox/LineEdit

func _ready():
	init()


func init():
	value = initial_value
	update_value()
	repeat_delay.wait_time = repeat_delay_secs
	repeat_interval.wait_time = repeat_interval_secs


func button_pressed(up_button:bool): # refactor: rename to on_button_pressed, reconnect
	if up_button:
		value += step
		repeat_increment_value = step
		emit_signal("button_pressed", "up")
	else:
		value -= step
		repeat_increment_value = -step
		emit_signal("button_pressed", "down")
	update_value()
	last_valid_value = value
	either_button_down = true
	if repeat_delay_started:
		return
	repeat_delay.start()
	repeat_delay_started = true


func button_unpressed(_up_button:bool): # refactor: rename to on_button_unpressed, reconnect
	either_button_down = false
	repeat_delay.stop()
	repeat_delay_started = false


func on_text_changed(new_text):
	last_valid_value = value
	new_text = new_text.to_lower()
	var input_denied: bool = false # refactor: consolidate into text_is_numeric() function
	var problem_characters: Array = []
	if "." in new_text:
		print_debug("This spinbox is not configured for floats.")
	for non_numeric_character in common_inputs:
		if non_numeric_character in new_text:
			problem_characters.append(non_numeric_character)
			input_denied = true
	for non_numeric_character in symbol_inputs:
		if input_denied:
			break
		if non_numeric_character in new_text:
			problem_characters.append(non_numeric_character)
			input_denied = true
	for non_numeric_character in accent_inputs:
		if input_denied:
			break
		if non_numeric_character in new_text:
			problem_characters.append(non_numeric_character)
			input_denied = true
	if input_denied:
		use_last_valid_value()
		print_debug("Non-numeric characters found: %s" % [problem_characters])
		return
	# if we made it this far, we should have a valid-looking input
	value = new_text as int # any non-numeric characters get removed here
	emit_signal("value_changed", value)
	last_valid_value = value


func repeat_delay_timeout(): # refactor: rename to on_repeat_delay_timeout, reconnect
	repeat_delay_started = false
	while either_button_down:
		value += repeat_increment_value
		update_value()
		repeat_interval.start()
		yield(repeat_interval,"timeout")
		if all_nodes_lost_focus() == true:
			print_debug("Focus dropped on %s, ending repeat input prematurely." % [name])
			either_button_down = false


func item_focus_entered(): # refactor: rename to child_focus_entered, reconnect
	either_button_down = false


func item_focus_exited(): # refactor: rename to child_focus_exited, reconnect
	update_value()
	# focus entry takes a cycle after this callback is called.
	yield(get_tree(),"idle_frame") # without waiting first, nothing is focused for a cycle :(
	if all_nodes_lost_focus() == true:
		emit_signal("focus_fully_exited")
		#print_debug("All nodes of %s fully exited focus." % [name])


func all_nodes_lost_focus() -> bool:
	if (line_edit.has_focus() == false) and (up.has_focus() == false) and (down.has_focus() == false):
		emit_signal("focus_fully_exited")
		return true
	return false


func string_is_numeric(new_text:String) -> bool:
	for non_numeric_character in common_inputs:
		if non_numeric_character in new_text:
			return false
	for non_numeric_character in symbol_inputs:
		if non_numeric_character in new_text:
			return false
	for non_numeric_character in accent_inputs:
		if non_numeric_character in new_text:
			return false
	return true


func update_value():
	if round_to_step:
		value -= (value % step)
	if value > max_range:
		value = max_range
	if value < min_range:
		value = min_range
	emit_signal("value_changed", value)
	line_edit.text = "%s" % [value]


func use_last_valid_value():
	value = last_valid_value
	update_value()
	line_edit.caret_position = line_edit.text.length()
