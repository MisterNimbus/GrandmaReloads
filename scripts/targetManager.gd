extends Node2D

@onready var left_top_spawn: Marker2D = $LeftTopSpawn
@onready var left_middle_spawn: Marker2D = $LeftMiddleSpawn
@onready var left_bottom_spawn: Marker2D = $LeftBottomSpawn

@onready var right_top_spawn: Marker2D = $RightTopSpawn
@onready var right_middle_spawn: Marker2D = $RightMiddleSpawn
@onready var right_bottom_spawn: Marker2D = $RightBottomSpawn

@onready var spawn_markers = [
	left_top_spawn, left_middle_spawn, left_bottom_spawn,
	right_top_spawn, right_middle_spawn, right_bottom_spawn
]

@onready var timer: Timer = $Timer

@export var target_scene: PackedScene

func  _ready() -> void:
	timer.start(randf_range(0.5, 2.0))
	
func _spawn_target():
	var spawn_point: Marker2D = spawn_markers.pick_random() 
	var target = target_scene.instantiate()
	add_child(target)
	target.global_position = spawn_point.global_position
	var direction := 1.0 if spawn_point.global_position.x < global_position.x else -1.0
	target.spawn(direction)

func _on_timer_timeout() -> void:
	_spawn_target()
	timer.start(randf_range(0.5, 2.0))

func _on_weapon_manager_gun_fired(damage: int, spread_radius: float) -> void:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	
	var hits := get_world_2d().direct_space_state.intersect_point(query)
	
	for result in hits:
		var target = result.collider
		if target.has_method("hit"):
			target.hit(damage)
			break
