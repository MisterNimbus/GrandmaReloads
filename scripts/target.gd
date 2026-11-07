extends RigidBody2D

func _process(delta: float) -> void:
	pass
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			linear_velocity = Vector2.ZERO
