class_name WorldTimeManager
extends Node

signal time_changed(time_of_day: float)
signal day_changed(day: int)

@export_category("World Time")
@export var day_length_seconds: float = 1200.0
@export_range(0.0, 24.0, 0.01) var time_of_day: float = 8.0
@export var current_day: int = 1

@export_category("Simulation")
@export var world_time_scale: float = 1.0
@export var is_paused: bool = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_paused:
		return

	if day_length_seconds <= 0.0:
		return

	var hours_per_second := 24.0 / day_length_seconds
	var hours_advanced := delta * hours_per_second * world_time_scale
	advance_time(hours_advanced)


## Returns the current world time in hours.
func get_time() -> float:
	return time_of_day


## Returns the current world time normalized to a range from 0.0 to below 1.0.
func get_normalized_time() -> float:
	return time_of_day / 24.0


## Returns the current world day.
func get_day() -> int:
	return current_day


## Sets the current world time without changing the current day.
func set_time(hours: float) -> void:
	var new_time := fposmod(hours, 24.0)

	if is_equal_approx(time_of_day, new_time):
		return

	time_of_day = new_time
	time_changed.emit(time_of_day)


## Sets the current world day.
func set_day(day: int) -> void:
	var new_day: int = max(day, 1)

	if current_day == new_day:
		return

	current_day = new_day
	day_changed.emit(current_day)


## Advances the world time by the specified number of hours.
func advance_time(hours: float) -> void:
	if is_zero_approx(hours):
		return

	var total_hours := time_of_day + hours
	var day_offset := floori(total_hours / 24.0)

	time_of_day = fposmod(total_hours, 24.0)

	if day_offset != 0:
		current_day = max(current_day + day_offset, 1)
		day_changed.emit(current_day)

	time_changed.emit(time_of_day)


## Sets the speed multiplier for simulated world time.
func set_world_time_scale(scale: float) -> void:
	world_time_scale = max(scale, 0.0)


## Pauses the world clock.
func pause_time() -> void:
	is_paused = true


## Resumes the world clock.
func resume_time() -> void:
	is_paused = false
