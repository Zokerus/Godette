extends Node
class_name CombatComponent

enum CombatMode {
	MELEE,
	RANGED,
	MAGIC
}

var activeCombatMode: CombatMode = CombatMode.MELEE
var isPerformingAction := false
var isDefending := false

func canStartAction() -> bool:
	return !isPerformingAction and !isDefending

func startAction() -> void:
	isPerformingAction = true

func finishAction() -> void:
	isPerformingAction = false

func startDefend() -> void:
	if !isPerformingAction:
		isDefending = true

func stopDefend() -> void:
	isDefending = false

func setCombatMode(mode: CombatMode) -> void:
	if !isPerformingAction:
		activeCombatMode = mode
