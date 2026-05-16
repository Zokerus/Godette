class_name Enemy
extends CharacterBody3D

enum EnemyState {
	IDLE,
	CHASE,
	ATTACK_PREPARE,
	ATTACK,
	SEARCH,
}

@export var moveSpeed: float = 2.0
@export var attackRange: float = 1.8
@export var attackCooldown: float = 1.2
@export var attackPrepareTime: float = 0.3

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var state_component: StateComponent = $StateComponent
@onready var vision_component: VisionComponent = $VisionComponent
@onready var rig_yaw_pivot: Node3D = $RigYawPivot
@onready var character: CharacterContext = $CharacterContext
@onready var attack_timer: Timer = $Timers/AttackTimer
@onready var prepare_timer: Timer = $Timers/PrepareTimer
@onready var combat_component: CombatComponent = $CombatComponent

var pointOfOrigin:= Vector3.ZERO
