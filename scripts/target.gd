class_name Target
extends RigidBody2D

func _process(delta: float) -> void:
	pass
	
func hit(damage: float) -> void:
	linear_velocity = Vector2.ZERO
