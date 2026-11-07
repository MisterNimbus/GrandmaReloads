extends Gun
class_name Shotgun

@export var spread_radius: float = 75.0 # Pixels around the crosshair that take damage

func _init() -> void:
	gun_id = "shotgun"
	max_ammo = 2 # Double barrel
	damage = 25
	fire_delay = 0.8

# Overriding the base fire method to include spread
func _fire() -> void:
	current_ammo -= 1
	can_shoot = false
	
	# Emit the signal with the shotgun's spread radius
	fired.emit(damage, spread_radius) 
	
	await get_tree().create_timer(fire_delay).timeout
	can_shoot = true
