extends Node2D

@onready var launch_from_left: Marker2D = $LaunchFromLeft
@onready var launch_from_right: Marker2D = $LaunchFromRight
@onready var timer: Timer = $Timer

@export var target_scene: PackedScene

func  _ready() -> void:
	timer.start(randf_range(0.5, 2.0))
	
func _spawn_target():
	var target = target_scene.instantiate()
	add_child(target)
	
	if randf() < 0.5:
		target.global_position = launch_from_left.global_position
		target.linear_velocity = Vector2(1200, -1200)
	else:
		target.global_position = launch_from_right.global_position
		target.linear_velocity = Vector2(-1200, -1200) 

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
