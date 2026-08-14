class_name Fireball
extends Projectile

var direction: Vector3

const SPEED = 5.0 # temp moving speed, might change in the future

func _ready() -> void:
	basic_damage = 10

func initialize(dir: Vector3)-> void:
	direction = dir


func _physics_process(delta: float) -> void:
	position += direction.normalized() * SPEED *delta


func _on_body_entered(body: Node3D) -> void:
	var combat_component := body.get_node_or_null("CombatComponent") as CombatComponent
	if combat_component == null:
		return
	
	combat_component.getHit(&"LightHit", get_damage())
	queue_free()
