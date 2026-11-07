extends CanvasLayer
class_name ReloadMinigame

signal reload_finished
signal minigame_closed

@onready var tooltip_label: Label = $TooltipLabel
@export var instruction_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if tooltip_label:
		tooltip_label.text = ""
	_connect_tooltips()
	
func _input(event: InputEvent) -> void:
	# If they press Reload again, or press Esc (assuming "ui_cancel" is mapped to Esc)
	if event.is_action_pressed("reload") or event.is_action_pressed("ui_cancel"):
		# Stop this input from triggering other things behind the screen
		get_viewport().set_input_as_handled() 
		minigame_closed.emit()

# Automatically finds all items and zones in this scene and wires up the tooltips
func _connect_tooltips() -> void:
	# We use a recursive function to find all children that are Items or Zones
	var all_nodes = _get_all_children(self)
	for node in all_nodes:
		if node is InteractableItem:
			node.hover_started.connect(_on_hover_started)
			node.hover_ended.connect(_on_hover_ended)
		elif node is DropZone:
			node.mouse_entered.connect(_on_hover_started.bind(node.zone_name))
			node.mouse_exited.connect(_on_hover_ended)

func _on_hover_started(hover_text: String) -> void:
	if tooltip_label: tooltip_label.text = hover_text

func _on_hover_ended() -> void:
	if tooltip_label: tooltip_label.text = ""

# Helper to get every nested child node
func _get_all_children(node: Node) -> Array:
	var nodes = []
	for child in node.get_children():
		nodes.append(child)
		nodes.append_array(_get_all_children(child))
	return nodes

# Call this from your specific minigame logic when the gun is fully loaded
func finish_minigame() -> void:
	reload_finished.emit()
