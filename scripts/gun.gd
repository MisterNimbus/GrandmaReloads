extends Node2D
class_name Gun

signal trigger_pulled ## Emitted exactly when you click (for flash pans / trigger effects)
signal fired(damage: int, spread_radius: float) ## Emitted when the projectile actually fires
signal out_of_ammo
signal reload_requested(gun_id: String)
signal weapon_switched(crosshair: Texture2D)

@export_category("Gun Stats")
@export var gun_id: String = "base_gun"
@export var max_ammo: int = 6
@export var damage: int = 10
@export var ignition_delay: float = 0.0 ## Set > 0.0 for Muzzleloader delay
@export var fire_delay: float = 0.5 

@export_category("Recoil")
@export var recoil_distance: float = 15.0 ## How far back it kicks per shot
@export var max_recoil_distance: float = 30.0 ## Max accumulation for automatic rapid fire
@export var recoil_kick_time: float = 0.05 ## How fast it snaps back (usually very quick)
@export var recoil_recovery_time: float = 0.25 ## How long it takes to settle back to normal

@export_category("Visuals")
@export var view_model_straight_texture: Texture2D
@export var view_model_left_texture: Texture2D
@export var view_model_right_texture: Texture2D
@export var crosshair_texture: Texture2D 
## Shifts the sprite so it rotates from the stock/grip rather than the center
@export var sprite_offset: Vector2 = Vector2.ZERO

@export_category("Audio")
@export var shoot_sound: AudioStream
@export var empty_click_sound: AudioStream

@export_category("Reloading")
@export var reload_minigame_scene: PackedScene

var current_ammo: int
var can_shoot: bool = true

var audio_player: AudioStreamPlayer
var sprite: Sprite2D

var sprite_original_position: Vector2
var recoil_tween: Tween

func _ready() -> void:
	current_ammo = max_ammo	
	# Safely grab or create the Audio Player
	audio_player = get_node_or_null("AudioStreamPlayer")
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		audio_player.name = "AudioStreamPlayer"
		add_child(audio_player)
	
	# Safely grab or create the Sprite
	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	
	if view_model_straight_texture:
		sprite.texture = view_model_straight_texture
		
	sprite_original_position = sprite.position

# Track the mouse every frame
func _process(_delta: float) -> void:
	if not is_visible_in_tree() or not sprite:
		return
	
	look_at(get_global_mouse_position())
	
	if abs(global_rotation_degrees) > 100:
		sprite.texture = view_model_left_texture
	elif abs(global_rotation_degrees) < 80:
		sprite.texture = view_model_right_texture
	else:
		sprite.texture = view_model_straight_texture
		
func equip() -> void:
	show()
	weapon_switched.emit(crosshair_texture)

func unequip() -> void:
	hide()

func try_fire() -> bool:
	if not can_shoot:
		return false
		
	if current_ammo <= 0:
		_play_sound(empty_click_sound)
		out_of_ammo.emit()
		return false
		
	_fire()
	return true

func _fire() -> void:
	current_ammo -= 1
	can_shoot = false
	
	# 1. Trigger pull (instant)
	trigger_pulled.emit()
	
	# 2. Wait for ignition delay (bypassed if 0.0)
	if ignition_delay > 0.0:
		await get_tree().create_timer(ignition_delay).timeout
	
	# 3. Actual firing
	_play_sound(shoot_sound)
	fired.emit(damage, 0.0) 
	_apply_recoil()
	
	# 4. Wait for mechanical cooldown
	await get_tree().create_timer(fire_delay).timeout
	can_shoot = true

func _apply_recoil() -> void:
	if not is_instance_valid(sprite):
		return
		
	# If a tween is already running (because of rapid fire), kill it!
	# This interrupts the recovery and lets us push the gun even further back from its current spot.
	if recoil_tween and recoil_tween.is_valid():
		recoil_tween.kill()
		
	recoil_tween = create_tween()
	
	# Calculate the target backward position. 
	# We use max() to cap it so an automatic weapon doesn't fly off the screen.
	var target_x = max(sprite.position.x - recoil_distance, sprite_original_position.x - max_recoil_distance)
	var target_pos = Vector2(target_x, sprite.position.y)
	
	# Step 1: The fast kick backward (happens in a tiny fraction of a second)
	recoil_tween.tween_property(sprite, "position", target_pos, recoil_kick_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# Step 2: The smooth recovery back to normal. 
	# Tweens automatically queue sequentially, so this waits for Step 1 to finish.
	recoil_tween.tween_property(sprite, "position", sprite_original_position, recoil_recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _play_sound(stream: AudioStream) -> void:
	if stream and is_instance_valid(audio_player):
		audio_player.stream = stream
		audio_player.play()

func request_reload() -> void:
	if current_ammo < max_ammo:
		reload_requested.emit(gun_id)

func complete_reload() -> void:
	current_ammo = max_ammo
