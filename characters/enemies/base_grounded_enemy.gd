extends CharacterBody2D

var enemy_color: int = 0


const SPEED = 100.0
var x_direction: int
var target: CharacterBody2D




func _enter_tree() -> void:
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
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()



func _alter_target(player_color: int) -> void:
	if player_color == enemy_color:
		print("he just like me fr")
		target = null