extends CharacterBody2D

var enemy_color: int = Globals.MaskColors.BLUEMASK


const SPEED = 100.0
var x_direction: int
var target: CharacterBody2D




func _enter_tree() -> void:
	set_collision_layer_value(enemy_color, true)
	print(get_collision_layer_value(3))
	SignalBus.player_picked_up_mask.connect(_alter_target)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if target != null:
		x_direction = 1 if (global_position.x - target.global_position.x < 0.0) else -1
		self.velocity.x = x_direction * SPEED * delta * 60
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()



func _alter_target(player_color: int) -> void:
	if player_color == enemy_color:
		target = null