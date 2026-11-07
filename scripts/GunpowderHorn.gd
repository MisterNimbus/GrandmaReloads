extends InteractableItem
class_name GunpowderHorn

@export_category("Horn Spawner")
@export var particle_scene: PackedScene
@export var min_spawn_rate: float = 0.2 
@export var max_spawn_rate: float = 0.02 
@export var rotation_speed: float = 5.0 

@export_category("Spawning Angles")
@export_range(0.0, 1.0) var min_tilt_threshold: float = 0.1
@export_range(0.0, 1.0) var max_tilt_threshold: float = 1.0

@onready var nozzle: Marker2D = $Nozzle

var spawn_timer: float = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta) 
	
	if is_dragged:
		_handle_rotation(delta)
		_handle_spawning(delta)

func _handle_rotation(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		global_rotation -= rotation_speed * delta
	elif Input.is_action_pressed("ui_down"):
		global_rotation += rotation_speed * delta

func _handle_spawning(delta: float) -> void:
	# Calculate the exact direction from the horn's pivot center to the nozzle.
	# This automatically works no matter which way your sprite was drawn!
	var nozzle_dir = (nozzle.global_position - global_position).normalized()
	
	# nozzle_dir.y gets the vertical direction. 1.0 is straight down, 0.0 is horizontal.
	var downward_tilt = nozzle_dir.y
	
	if downward_tilt >= min_tilt_threshold:
		spawn_timer -= delta
		
		if spawn_timer <= 0:
			# Pass the direction to the spawn function so it shoots out correctly
			_spawn_particle(nozzle_dir)
			
			var tilt_factor = clamp((downward_tilt - min_tilt_threshold) / (max_tilt_threshold - min_tilt_threshold), 0.0, 1.0)
			spawn_timer = lerpf(min_spawn_rate, max_spawn_rate, tilt_factor)

func _spawn_particle(direction: Vector2) -> void:
	if not particle_scene:
		return
		
	var particle = particle_scene.instantiate()
	get_parent().add_child(particle) 
	
	particle.global_position = nozzle.global_position
	
	# Push the particle out in the exact direction the tip is pointing
	particle.linear_velocity = direction * randf_range(50.0, 100.0)
