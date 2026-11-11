extends Target

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var break_particles: GPUParticles2D = $BreakParticles
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export var drone_lookahead := 80.0
@export var flight_speed := 200.0
@export var steering_gain := 4.0
@export var max_steering_force := 350.0 

var route: Curve2D
var broken := false

func _init() -> void:
	target_type = TargetType.DRONE

func _physics_process(delta: float) -> void:
	if route == null:
		return
	
	var progress := route.get_closest_offset(position)
	var lookahead := minf(progress + drone_lookahead, route.get_baked_length())
	var target := route.sample_baked(lookahead)
	
	var desired_velocity := global_position.direction_to(target) * flight_speed
	var steering_force := (desired_velocity - linear_velocity) * steering_gain
	apply_central_force(steering_force.limit_length(max_steering_force))
	
func set_route(drone_route: Curve2D) -> void:
	route = drone_route

func hit(damage: float) -> void:
	if broken:
		return
	broken = true
	
	super.hit(damage)
	sprite_2d.hide()
	collision_polygon_2d.set_deferred("disabled", true)
	freeze = true
	break_particles.emitting = true
	await break_particles.finished
	queue_free()
