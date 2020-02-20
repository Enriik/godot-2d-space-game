extends Node

export var map_transition_time := 0.35

var _spawned_positions := []
var _world_objects := []
var _map_up := false

onready var pirate_spawner := $World/PirateSpawner
onready var station_spawner := $World/StationSpawner
onready var asteroid_spawner := $World/AsteroidSpawner
onready var map := $MapViewport
onready var camera := $World/Camera
onready var world := $World


func _ready() -> void:
	# warning-ignore:return_value_discarded
	station_spawner.connect("station_spawned", self, "_on_Spawner_station_spawned")
	# warning-ignore:return_value_discarded
	asteroid_spawner.connect("asteroid_spawned", self, "_on_Spawner_asteroid_spawned")
	
	camera.setup_camera_map(map)

	station_spawner.spawn_station()

	world.setup()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		_map_up = not _map_up
		get_tree().call_group("MapControls", "_toggle_map", _map_up, map_transition_time)


func _on_Spawner_pirate_spawned(pirate: Node) -> void:
	pirate.register_on_map(map)
	pirate.setup_world_objects(_world_objects)


func _on_Pirate_cluster_spawned(pirates: Array) -> void:
	var leader: KinematicBody2D = pirates[0]
	leader.is_squad_leader = true
	var nearest_asteroid: Vector2
	var min_distance := INF
	var cluster_position := leader.global_position
	for a in asteroid_spawner.get_children():
		var distance := cluster_position.distance_to(a.global_position)
		if distance < min_distance:
			nearest_asteroid = a.global_position
			min_distance = distance
	for p in pirates:
		p.setup_squad(p == leader, leader, nearest_asteroid, pirates)


func _on_Spawner_station_spawned(station: Node, _player: KinematicBody2D) -> void:
	_world_objects.append(station)
	station.register_on_map(map)

	_player.register_on_map(map)
	_player.grab_camera(camera)


func _on_Spawner_asteroid_spawned(asteroid: Node) -> void:
	asteroid.register_on_map(map)
	_world_objects.append(asteroid)
