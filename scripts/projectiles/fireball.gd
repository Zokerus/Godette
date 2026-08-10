class_name Fireball
extends Area3D

var direction: Vector3

const SPEED = 5.0 # temp moving speed, might change in the future

func initialize(dir: Vector3)-> void:
	direction = dir

func _physics_process(delta: float) -> void:
	position += direction * SPEED *delta
