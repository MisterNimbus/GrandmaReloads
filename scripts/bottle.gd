extends Target
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var break_particles: GPUParticles2D = $BreakParticles
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var broken := false

func _ready() -> void:	
	# Delete the particle when it falls off the bottom of the screen
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)

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

func spawn(direction):
	linear_velocity = Vector2(
		direction * randf_range(500, 1200),
		 -1 * randf_range(500, 1200)
		)
		
	angular_velocity = randf_range(-8, 8)
