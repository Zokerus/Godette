class_name StateComponent
extends Node

signal state_changed(newState)

var currentState: int

func change_state(newState) -> void:
	if currentState == newState:
		return
	print(newState)
	currentState = newState
	
	state_changed.emit(currentState)
