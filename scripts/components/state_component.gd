class_name StateComponent
extends Node

signal state_changed(oldState, newState)

var currentState: int

func change_state(newState) -> void:
	if currentState == newState:
		return
		
	var old := currentState
	currentState = newState
	
	state_changed.emit(old, currentState)
