class_name Target
extends RigidBody2D

enum TargetType {BOTTLE, DRONE}

var target_type: TargetType

func hit(damage: float) -> void:
	linear_velocity = Vector2.ZERO
