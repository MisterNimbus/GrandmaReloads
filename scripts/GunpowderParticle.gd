extends InteractableItem
class_name GunpowderParticle

@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	# Call the parent InteractableItem setup
	super._ready() 
	
	item_id = "gunpowder_particle"
	hover_name = "" # No tooltip for tiny particles
	
	# Delete the particle when it falls off the bottom of the screen
	screen_notifier.screen_exited.connect(queue_free)

# Override the input events so the player can't grab them
func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass

func _input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	pass
