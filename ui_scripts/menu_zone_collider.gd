extends CollisionShape2D

const ACTIVATION_TIME = 3.0  # 3 seconds
const TARGET_COLOR = Color.DARK_BLUE
const START_COLOR = Color.WHITE
const COLOR_LERP_SCALE = 0.01

var area_2d: Area2D
var label_group: Node2D
var timer: float = 0.0
var player_in_zone: bool = false
var zone_type: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the parent Area2D
	area_2d = get_parent() as Area2D
	label_group = area_2d.get_parent()
	if not area_2d:
		push_error("menu_zone_collider: Parent must be an Area2D")
		return
	
	# Connect to area signals
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
	# Determine zone type based on parent node name
	var parent_label = area_2d.get_parent()
	if parent_label:
		var label_name = parent_label.name
		if "Play" in label_name:
			zone_type = "Play"
		elif "Options" in label_name:
			zone_type = "Options"
		elif "Exit" in label_name:
			zone_type = "Exit"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_zone:
		timer += delta
		# Step color toward TARGET_COLOR
		label_group.modulate = lerp(label_group.modulate, TARGET_COLOR, COLOR_LERP_SCALE)
		
		if timer >= ACTIVATION_TIME:
			_activate_zone()
			timer = 0.0  # Reset after activation
			player_in_zone = false  # Prevent multiple activations
			label_group.modulate = START_COLOR

func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player (using the "player" group)
	if body.is_in_group("player"):
		player_in_zone = true
		timer = 0.0  # Start counting from 0

func _on_body_exited(body: Node2D) -> void:
	# Check if the body is the player
	if body.is_in_group("player"):
		player_in_zone = false
		timer = 0.0  # Reset timer when player leaves
		label_group.modulate = START_COLOR

func _activate_zone() -> void:
	match zone_type:
		"Exit":
			get_tree().quit()
		"Options":
			# Placeholder - do nothing
			pass
		"Play":
			var next_level = load("res://levels/level_2.tscn")
			get_tree().change_scene_to_packed(next_level)
