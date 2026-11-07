extends Area2D
class_name DropZone

signal item_accepted(item: InteractableItem)
signal item_rejected(item: InteractableItem)

@export var zone_name: String = "Drop Zone" 
@export var accepted_item_ids: Array[String] = ["bullet"] 
@export var consume_item_on_accept: bool = true 

@export_category("Interaction Rules")
## If TRUE, player must release the mouse to drop the item in.
## If FALSE, the item is accepted the moment it enters the area.
@export var require_drop: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is InteractableItem:
		if require_drop:
			# Wait for the player to let go of the mouse
			if not body.dropped.is_connected(_on_item_dropped):
				body.dropped.connect(_on_item_dropped)
		else:
			# Instant acceptance upon touching
			_try_accept_item(body)

func _on_body_exited(body: Node2D) -> void:
	if body is InteractableItem:
		# If they drag it back out before dropping, disconnect it
		if body.dropped.is_connected(_on_item_dropped):
			body.dropped.disconnect(_on_item_dropped)

func _on_item_dropped(item: InteractableItem) -> void:
	_try_accept_item(item)

# Central validation so we don't repeat code for instant vs dropped
func _try_accept_item(item: InteractableItem) -> void:
	if accepted_item_ids.is_empty() or item.item_id in accepted_item_ids:
		# Passes it to the overridable _can_accept function for complex logic
		if _can_accept(item):
			_process_accepted_item(item)
		else:
			item_rejected.emit(item)
	else:
		item_rejected.emit(item)

# Allows subclasses (like MuzzleZone) to add extra rules, like checking if powder is in first
func _can_accept(_item: InteractableItem) -> bool:
	return true

# Executes the actual consumption of the item
func _process_accepted_item(item: InteractableItem) -> void:
	item_accepted.emit(item)
	
	if consume_item_on_accept:
		if item.dropped.is_connected(_on_item_dropped):
			item.dropped.disconnect(_on_item_dropped)
			
		# Force the item to stop dragging so the mouse state resets correctly
		item.is_dragged = false 
		item.queue_free()
