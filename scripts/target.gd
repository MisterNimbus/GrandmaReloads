class_name Target
extends RigidBody2D

func hit(damage: float) -> void:
	linear_velocity = Vector2.ZERO

func spawn(direction: float) -> void:
	pass
