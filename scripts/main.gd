extends Node
@onready var tooltip_label: Label = $TooltipLabel

func _ready() -> void:
	# Find all items in the scene and wire up their hover signals
	for node in get_tree().get_nodes_in_group("interactables"):
		if node is InteractableItem:
			node.hover_started.connect(_on_item_hovered)
			node.hover_ended.connect(_clear_tooltip)
			
	for node in get_tree().get_nodes_in_group("drop_zones"):
		if node is DropZone:
			node.zone_hovered.connect(_on_zone_hovered)

func _on_item_hovered(item: InteractableItem) -> void:
	tooltip_label.text = item.hover_name

func _on_zone_hovered(zone_name: String) -> void:
	tooltip_label.text = zone_name

func _clear_tooltip(_item = null) -> void:
	tooltip_label.text = ""
