extends Node
@onready var tooltip_label: Label = $TooltipLabel
@onready var background: TextureRect = $Background
@onready var viewport_rect: Rect2 = background.get_viewport_rect()

var initial_background_center: Vector2

func _ready() -> void:
	# Find all items in the scene and wire up their hover signals
	for node in get_tree().get_nodes_in_group("interactables"):
		if node is InteractableItem:
			node.hover_started.connect(_on_item_hovered)
			node.hover_ended.connect(_clear_tooltip)
			
	for node in get_tree().get_nodes_in_group("drop_zones"):
		if node is DropZone:
			node.zone_hovered.connect(_on_zone_hovered)
	
	# Allign background image to the center	
	var centered_x: float = (viewport_rect.size.x - background.size.x) / 2.0
	var centered_y: float = (viewport_rect.size.y - background.size.y) / 2.0
	background.position.x = centered_x
	background.position.y = centered_y
	initial_background_center = background.position

func _process(delta: float) -> void:
	_allign_background(delta)

func _on_item_hovered(item: InteractableItem) -> void:
	tooltip_label.text = item.hover_name

func _on_zone_hovered(zone_name: String) -> void:
	tooltip_label.text = zone_name

func _clear_tooltip(_item = null) -> void:
	tooltip_label.text = ""

func _allign_background(delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var mouse_offset = ((mouse_pos - viewport_rect.get_center()) / (viewport_rect.size/  2.0)).clamp(Vector2(-1, -1), Vector2(1, 1))
	var background_offset : Vector2 = background.size - viewport_rect.size
	var target_pos: Vector2 = initial_background_center - mouse_offset * background_offset / 2.0
	background.position = background.position.lerp(target_pos, 1.0 - exp(-5.0 * delta))
