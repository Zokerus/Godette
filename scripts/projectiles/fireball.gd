class_name Fireball
extends Area3D

var direction: Vector2

const SPEED = 5.0 # temp moving speed, might change in the future

func initialize(dir: Vector2)-> void:
	direction = dir

func _physics_process(delta: float) -> void:
	position += Vector3(direction.x, 0, direction.y) * SPEED *delta
