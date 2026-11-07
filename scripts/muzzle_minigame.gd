extends ReloadMinigame
class_name MuzzleMinigame

# Make sure this path matches your MuzzleZone node exactly
@onready var muzzle_zone: MuzzleZone = $MusketMuzzle/MuzzleZone

func _ready() -> void:
	# super._ready() runs the _ready function inside ReloadMinigame!
	# This automatically sets PROCESS_MODE_ALWAYS and connects your tooltips.
	super._ready()
	
	if instruction_label:
		instruction_label.text = "Step 1: Pour Gunpowder into Muzzle"
		
	if muzzle_zone:
		# Connect to the zone's signals
		muzzle_zone.item_accepted.connect(_on_item_accepted)
		muzzle_zone.muzzle_fully_loaded.connect(_on_fully_loaded)

# Update the instruction text as items are accepted
func _on_item_accepted(item: InteractableItem) -> void:
	if not instruction_label:
		return
		
	if item.item_id == "gunpowder_particle":
		# Check if we reached the required amount to ask for the ball
		if muzzle_zone.current_powder >= muzzle_zone.required_powder_amount:
			instruction_label.text = "Step 2: Insert Lead Ball"
		else:
			# Show a live counter as they pour
			instruction_label.text = "Pouring... (" + str(muzzle_zone.current_powder) + "/" + str(muzzle_zone.required_powder_amount) + ")"

# Caught the signal! Time to close the minigame.
func _on_fully_loaded() -> void:
	if instruction_label:
		instruction_label.text = "Loaded! Ready to fire."
		
	# Wait a fraction of a second so the player can actually read the final text
	await get_tree().create_timer(0.5).timeout
	
	# This function is inherited from ReloadMinigame.gd
	# It emits 'reload_finished', which tells WeaponManager to unpause and refill ammo
	finish_minigame()
