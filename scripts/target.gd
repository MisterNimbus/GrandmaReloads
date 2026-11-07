class_name Target
extends RigidBody2D

func _process(delta: float) -> void:
	if global_position.y > 1500:
		queue_free()
	
func hit(damage: float) -> void:
	linear_velocity = Vector2.ZERO

func spawn(direction: float) -> void:
	pass
