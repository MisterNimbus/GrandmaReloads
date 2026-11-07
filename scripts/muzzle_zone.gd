extends DropZone
class_name MuzzleZone

signal muzzle_fully_loaded

@export var required_powder_amount: int = 30
var current_powder: int = 0
var has_ball: bool = false

func _ready() -> void:
	# Call the base DropZone ready function so physics signals connect
	super._ready()
	
	# Force the base class to allow our specific items
	accepted_item_ids = ["gunpowder_particle", "lead_ball"]

func _can_accept(item: InteractableItem) -> bool:
	if item.item_id == "gunpowder_particle" and current_powder < required_powder_amount:
		return true
	elif item.item_id == "lead_ball" and current_powder >= required_powder_amount and not has_ball:
		return true
	return false

func _process_accepted_item(item: InteractableItem) -> void:
	if item.item_id == "gunpowder_particle":
		current_powder += 1
		#print("gunpowder detected. Total: ", current_powder)
		super._process_accepted_item(item) 
		
	elif item.item_id == "lead_ball":
		#print("ball detected.")
		has_ball = true
		super._process_accepted_item(item) 
		muzzle_fully_loaded.emit()
