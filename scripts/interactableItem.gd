extends RigidBody2D
class_name InteractableItem

signal hover_started(hover_name: String)
signal hover_ended
signal dropped(item: InteractableItem)

@export var item_id: String = "bullet" 
@export var hover_name: String = "Bullet"
@export var drag_force: float = 15.0

var is_hovered: bool = false
var is_dragged: bool = false
var original_gravity: float
var original_scale: Vector2
var hover_scale: Vector2

@onready var sprite: Sprite2D = $Sprite2D 

func _ready() -> void:
	original_gravity = gravity_scale
	original_scale = sprite.scale
	hover_scale = Vector2(sprite.scale.x * 1.1, sprite.scale.y * 1.1)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	is_hovered = true
	if sprite: sprite.scale = hover_scale 
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	hover_started.emit(hover_name)

func _on_mouse_exited() -> void:
	is_hovered = false
	# Only scale down if we aren't actively holding it
	if not is_dragged and sprite: sprite.scale = original_scale
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	hover_ended.emit()

func _input(event: InputEvent) -> void:
	# 1. Start dragging if we click while hovering
	if event.is_action_pressed("shoot") and is_hovered:
		is_dragged = true
		sleeping = false # Wake up physics engine
		
	# 2. Stop dragging if we let go of the mouse ANYWHERE
	elif event.is_action_released("shoot") and is_dragged:
		is_dragged = false
		gravity_scale = original_gravity
		
		if not is_hovered:
			if sprite: sprite.scale = original_scale
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			
		dropped.emit(self)

func _physics_process(_delta: float) -> void:
	if is_dragged:
		gravity_scale = 0
		# CRITICAL FIX: Use Viewport mouse position for CanvasLayer items
		var mouse_pos = get_viewport().get_mouse_position()
		var distance = global_position.distance_to(mouse_pos)
		var direction = global_position.direction_to(mouse_pos)
		
		linear_velocity = direction * distance * drag_force

# Safety catch: Reset the cursor if this item is destroyed while being hovered/held
func _exit_tree() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
