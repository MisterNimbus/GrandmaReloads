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

@onready var bottle_timer: Timer = $Bottle_Timer
@onready var drone_timer: Timer = $Drone_Timer

@export var bottle_scene: PackedScene
@export var drone_scene: PackedScene

# Store the base intervals here so they don't shrink when start() overwrites the timer's wait_time
@export var max_bottle_interval: float = 3.0 
@export var max_drone_interval: float = 12.0

func _ready() -> void:
	bottle_timer.start()
	drone_timer.start()
	
func spawn_target(type: Target.TargetType):
	var spawn_point: Marker2D = spawn_markers.pick_random()
	
	if type == Target.TargetType.BOTTLE and bottle_scene:
		var bottle: Node = bottle_scene.instantiate()
		add_child(bottle)
		bottle.global_position = spawn_point.global_position
		# Fixed direction check to be based on the TargetManager's center
		var direction := 1.0 if spawn_point.global_position.x < global_position.x else -1.0
		bottle.throw_bottle(direction)
	
	if type == Target.TargetType.DRONE and drone_scene:
		var drone: Node = drone_scene.instantiate()
		add_child(drone)
		drone.global_position = spawn_point.global_position
		var route: Curve2D = generate_drone_route(spawn_point.position)
		drone.set_route(route)
		
# Hit detection
func _on_weapon_manager_gun_fired(damage: int, spread_radius: float) -> void:
	# Note: This is currently a pinpoint check. If you want spread_radius to actually
	# increase the hit area, you should use PhysicsShapeQueryParameters2D with a CircleShape2D!
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	
	var hits := get_world_2d().direct_space_state.intersect_point(query)
	
	for result in hits:
		var target = result.collider
		if target.has_method("hit"):
			target.hit(damage)
			break # Stops the bullet from piercing multiple targets

func generate_drone_route(start_point: Vector2) -> Curve2D:
	var rect := Main.PLAYFIELD.grow(-200.0)
	var waypoint := Vector2(
		randf_range(rect.position.x, rect.end.x),
		randf_range(rect.position.y, rect.end.y)
	)
	var end_point := Vector2(waypoint.x, Main.PLAYFIELD.size.y * -2)
	var path := Curve2D.new()
	path.add_point(start_point)
	path.add_point(waypoint)
	path.add_point(end_point)   
	return path

func _on_bottle_timer_timeout() -> void:
	spawn_target(Target.TargetType.BOTTLE)
	bottle_timer.start(randf_range(1.0, max_bottle_interval))

func _on_drone_timer_timeout() -> void:
	spawn_target(Target.TargetType.DRONE)
	drone_timer.start(randf_range(8.0, max_drone_interval))
