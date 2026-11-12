extends Node2D
class_name WeaponManager

signal gun_fired(damage: int, spread_radius: float)

@export_category("Weapon Setup")
## Expand this array in the Inspector and drag your Gun nodes here
@export var weapons: Array[Gun] = []
## The index of the weapon the player starts the level with (0 is the first)
@export var starting_weapon_index: int = 0

@export_category("Input Actions")
@export var shoot_action: String = "shoot"
@export var reload_action: String = "reload"
@export var next_weapon_action: String = "next_weapon"
@export var prev_weapon_action: String = "prev_weapon"

var active_minigame: ReloadMinigame
var active_weapon_index: int = -1
var current_gun: Gun

func _ready() -> void:
	# 1. Clean the array to permanently remove any <empty> slots left in the Inspector
	var valid_weapons: Array[Gun] = []
	for weapon in weapons:
		if is_instance_valid(weapon):
			valid_weapons.append(weapon)
			
	weapons = valid_weapons

	if weapons.is_empty():
		push_warning("WeaponManager has no valid weapons assigned!")
		return

	# 2. Connect signals and hide all weapons initially
	for weapon in weapons:
		weapon.fired.connect(_on_gun_fired)
		weapon.out_of_ammo.connect(_on_out_of_ammo)
		weapon.reload_requested.connect(_on_reload_requested)
		weapon.weapon_switched.connect(_on_weapon_switched)
		weapon.unequip()
	
	# 3. Safely clamp the starting index so it can never be out of bounds
	starting_weapon_index = clampi(starting_weapon_index, 0, weapons.size() - 1)
	equip_weapon(starting_weapon_index)

func _input(event: InputEvent) -> void:
	if not is_instance_valid(current_gun): 
		return
	if is_instance_valid(active_minigame):
		return
		
	if event.is_action_pressed(shoot_action):
		current_gun.try_fire()
	elif event.is_action_pressed(reload_action):
		current_gun.request_reload()
		
	# Weapon switching logic (e.g., mouse scroll wheel)
	elif event.is_action_pressed(next_weapon_action):
		_switch_weapon(1)
	elif event.is_action_pressed(prev_weapon_action):
		_switch_weapon(-1)

# Handles cycling through the array safely
func _switch_weapon(direction: int) -> void:
	if weapons.size() <= 1: 
		return
	
	var new_index = (active_weapon_index + direction) % weapons.size()
	
	# Wrap around to the end of the array if scrolling backwards past 0
	if new_index < 0:
		new_index = weapons.size() - 1
		
	equip_weapon(new_index)

func equip_weapon(index: int) -> void:
	# Safety check: Does this index actually exist?
	if index < 0 or index >= weapons.size():
		return
		
	var next_gun = weapons[index]
	if not is_instance_valid(next_gun):
		return

	# Hide the old gun before swapping
	if active_weapon_index != -1 and is_instance_valid(current_gun):
		current_gun.unequip()
		
	active_weapon_index = index
	current_gun = next_gun
	current_gun.equip()

# --- Signal Callbacks ---

func _on_gun_fired(damage: int, spread: float) -> void:
	# Emit the manager's signal so your hit detection / level script can process the shot
	gun_fired.emit(damage, spread)

func _on_out_of_ammo() -> void:
	# Trigger UI elements (e.g., flashing "PRESS R")
	pass

func _on_reload_requested(_gun_id: String) -> void:
	if is_instance_valid(active_minigame):
		return
		
	if current_gun.reload_minigame_scene:        
		active_minigame = current_gun.reload_minigame_scene.instantiate()
		add_child(active_minigame)
		
		# Connect both signals
		active_minigame.reload_finished.connect(_on_minigame_finished)
		active_minigame.minigame_closed.connect(_close_minigame) # Triggers early exit
	else:
		push_warning("No minigame assigned to " + current_gun.name)

func _on_minigame_finished() -> void:
	if is_instance_valid(current_gun):
		current_gun.complete_reload() 
	_close_minigame()

func _on_weapon_switched(crosshair: Texture2D) -> void:
	if crosshair:
		Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_ARROW, crosshair.get_size() / 2.0)

func _close_minigame() -> void:
	get_tree().paused = false 
	
	if is_instance_valid(active_minigame):
		active_minigame.queue_free()
		active_minigame = null
