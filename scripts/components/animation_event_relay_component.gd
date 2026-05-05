extends Node
class_name AnimationEventRelay

signal animationEventReceived(eventName: StringName)

func emitEvent(eventName: StringName) -> void:
	animationEventReceived.emit(eventName)
