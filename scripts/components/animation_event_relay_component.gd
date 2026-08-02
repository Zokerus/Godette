extends Node
class_name AnimationEventRelay

signal animationEventReceived(event: AnimationEvents)

enum AnimationEvents {
	ATTACK_FINISHED,
	COMBO_WINDOW_OPEN,
	JUMP_TAKEOFF,
	ACTIVATE_WEAPON_HITBOX,
	DEACTIVATE_WEAPON_HITBOX
}

func emitEvent(event: AnimationEvents) -> void:
	animationEventReceived.emit(event)
	
