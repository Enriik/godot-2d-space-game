extends KinematicBody2D

# warning-ignore:unused_signal
signal damaged(amount, origin)
signal died
#warning-ignore: unused_signal
signal force_undock


export var map_icon: Texture
export var color_map_icon := Color.white
export var scale_map_icon := 0.5
export var health_max := 100
export(int, LAYERS_2D_PHYSICS) var projectile_mask := 0
export var PopEffect: PackedScene

var can_dock := 0
var dockables := []
var _health := health_max

onready var shape := $CollisionShape
onready var agent: GSAISteeringAgent = $StateMachine/Move.agent
onready var camera_transform := $CameraTransform
onready var timer := $MapTimer
onready var cargo := $Cargo


func _ready() -> void:
	#warning-ignore:return_value_discarded
	connect("damaged", self, "_on_self_damaged")
	$Gun.projectile_mask = projectile_mask
	#warning-ignore:return_value_discarded
	$StateMachine/Move/Dock.connect("docked", cargo, "_on_Player_docked")
	#warning-ignore:return_value_discarded
	$StateMachine/Move/Dock.connect("undocked", cargo, "_on_Player_undocked")


func _toggle_map(map_up: bool, tween_time: float) -> void:
	if not map_up:
		timer.start(tween_time)
		yield(timer, "timeout")
	camera_transform.update_position = not map_up


func die() -> void:
	var effect := PopEffect.instance()
	effect.global_position = global_position
	ObjectRegistry.register_effect(effect)

	emit_signal("died")

	queue_free()


func register_on_map(map: Viewport) -> void:
	var id: int = map.register_map_object($MapTransform, map_icon, color_map_icon, scale_map_icon)
	#warning-ignore:return_value_discarded
	connect("died", map, "remove_map_object", [id])


func grab_camera(camera: Camera2D) -> void:
	camera_transform.remote_path = camera.get_path()


func _on_self_damaged(amount: int, _origin: Node) -> void:
	_health -= amount
	if _health <= 0:
		die()
