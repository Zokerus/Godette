class_name Fireball
extends Projectile

var direction: Vector3
var caster_node: Node3D

const SPEED = 5.0 # temp moving speed, might change in the future
const MAX_DISTANCE = 50.0 # maximum travel distance before dessolving

## Initializes the projectile with its caster, spawn position, and movement direction.
func initialize(caster: Node3D, pos: Vector3, dir: Vector3)-> void:
	caster_node = caster
	origin = pos
	direction = dir
	monitoring = true


func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * SPEED *delta
	if global_position.distance_to(origin) >= MAX_DISTANCE:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body == caster_node:
		return
	var combat_component := body.get_node_or_null("CombatComponent") as CombatComponent
	if combat_component != null:
		combat_component.getHit(&"LightHit", damage_package)
	
	queue_free()
