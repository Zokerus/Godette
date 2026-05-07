extends MeshInstance3D
class_name HeadFace

const faces := {
	"default": Vector3.ZERO,
	"blink": Vector3(0.0, 0.5, 0.0),
	"smile": Vector3(0.5, 0.0, 0.0),
	"angry": Vector3(0.5, 0.5, 0.0),
}

@onready var blink_timer: Timer = $BlinkTimer

var face_material: StandardMaterial3D
var currentExpression := &"default"
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	var mat := get_surface_override_material(0)

	if mat == null:
		mat = get_active_material(0)

	if mat == null:
		push_error("HeadFace: No material found.")
		return

	face_material = mat.duplicate()
	set_surface_override_material(0, face_material)

func changeFace(expression: StringName) -> void:
	if face_material == null:
		return

	if !faces.has(expression):
		push_warning("Unknown face expression: %s" % expression)
		return

	face_material.uv1_offset = faces[expression]

func _on_blink_timer_timeout() -> void:
	changeFace(&"blink")
	await get_tree().create_timer(0.15).timeout
	changeFace(currentExpression)
	blink_timer.wait_time = rng.randf_range(1.5, 3.0)
