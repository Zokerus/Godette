class_name Enemy
extends CharacterBody3D

enum EnemyState {
	IDLE,
	CHASE,
	ATTACK_PREPARE,
	ATTACK,
	RECOVER,
}

@export var moveSpeed: float = 2.0
@export var attackRange := 1.8
@export var attackCooldown := 1.2
@export var attackPrepareTime := 0.3

var state: EnemyState = EnemyState.IDLE

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var vision_component: VisionComponent = $VisionComponent
@onready var rig_yaw_pivot: Node3D = $RigYawPivot
@onready var character: CharacterContext = $CharacterContext
@onready var attack_timer: Timer = $Timers/AttackTimer
@onready var prepare_timer: Timer = $Timers/PrepareTimer
@onready var cool_down_timer: Timer = $Timers/CoolDownTimer
@onready var combat_component: CombatComponent = $CombatComponent
