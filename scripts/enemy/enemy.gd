class_name Enemy
extends CharacterBody3D

@export var moveSpeed: float = 2.0

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var vision_component: VisionComponent = $VisionComponent
@onready var rig_yaw_pivot: Node3D = $RigYawPivot
@onready var character: CharacterContext = $CharacterContext
