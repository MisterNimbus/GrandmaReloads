extends Node2D
class_name Gun

signal fired(damage: int, spread_radius: float)
signal out_of_ammo
signal reload_requested(gun_id: String)
signal weapon_switched(crosshair: Texture2D)
@export var texture_rect: TextureRect



@export_category("Gun Stats")
@export var gun_id: String = "base_gun"
@export var max_ammo: int = 6
@export var damage: int = 10
@export var fire_delay: float = 0.5 

@export_category("Visuals")
@export var view_model_straight_texture: Texture2D
@export var view_model_left_texture: Texture2D
@export var view_model_right_texture: Texture2D
@export var crosshair_texture: Texture2D 
## If your gun sprite is drawn facing UP instead of RIGHT, set this to 90 degrees
@export var sprite_rotation_offset: float = 90.0
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




func _ready() -> void:
	current_ammo = max_ammo
	
	# 1. Lock the gun's root position to the bottom center of the screen
	var screen_size = get_viewport_rect().size
	global_position = Vector2(screen_size.x / 2.0, screen_size.y)
	
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	sprite = Sprite2D.new()
	add_child(sprite)
	

	
	if view_model_straight_texture:
		sprite.texture = view_model_straight_texture
		sprite.offset = sprite_offset
		sprite.rotation_degrees = sprite_rotation_offset
		
		
	if texture_rect:
		var centered_x: float = (get_viewport_rect().size.x - texture_rect.size.x) / 2.0
		var centered_y: float = (get_viewport_rect().size.y - texture_rect.size.y) / 2.0
		texture_rect.position.x = centered_x
		texture_rect.position.y = centered_y

# Track the mouse every frame
func _process(delta: float) -> void:
	
	if not is_visible_in_tree():
		return
	
	look_at(get_global_mouse_position())
	
		
	if abs(global_rotation_degrees) > 100:
		sprite.texture = view_model_left_texture

	elif abs(global_rotation_degrees) < 80:
		sprite.texture = view_model_right_texture
	else:
		sprite.texture = view_model_straight_texture
		
	
	
	
	if texture_rect:
		var centered_x: float = (get_viewport_rect().size.x - texture_rect.size.x) / 2.0
		var centered_y: float = (get_viewport_rect().size.y - texture_rect.size.y) / 2.0
		var background_offset = ((abs(global_rotation_degrees) - 90) / 90 ) * 36
		texture_rect.position.x = centered_x + background_offset
		texture_rect.position.y = centered_y - abs(background_offset)
		
		
		


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
	
	_play_sound(shoot_sound)
	fired.emit(damage, 0.0) 
	
	await get_tree().create_timer(fire_delay).timeout
	can_shoot = true

func _play_sound(stream: AudioStream) -> void:
	if stream:
		audio_player.stream = stream
		audio_player.play()

func request_reload() -> void:
	if current_ammo < max_ammo:
		reload_requested.emit(gun_id)

func complete_reload() -> void:
	current_ammo = max_ammo
