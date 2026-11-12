extends Gun
class_name MuzzleLoader

@export_category("Muzzleloader Particles")
@export var flash_pan_particles: Array[GPUParticles2D] = []
@export var muzzle_particles: Array[GPUParticles2D] = []

func _init() -> void:
	gun_id = "muzzle_loader"
	max_ammo = 1
	damage = 50
	fire_delay = 0.1
	ignition_delay = 0.15 # This creates the classic flintlock delay

func _ready() -> void:
	super._ready() # Crucial: Runs the node generation/adoption in the base Gun script!
	
	trigger_pulled.connect(_on_trigger_pulled)
	fired.connect(_on_fired)

func _on_trigger_pulled() -> void:
	print("Trigger Pulled! Muzzle particles array size: ", muzzle_particles.size()) # ADD THIS LINE
	for particle in flash_pan_particles:
		if is_instance_valid(particle):
			particle.restart()

func _on_fired(_dmg: int, _spread: float) -> void:
	print("Gun fired! Muzzle particles array size: ", muzzle_particles.size()) # ADD THIS LINE
	
	for particle in muzzle_particles:
		if is_instance_valid(particle):
			particle.restart()
