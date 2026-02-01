extends CharacterBody2D


@export_enum("Blue:3", "Red:4", "Yellow:5") var enemy_color: int

var mask_color_modulate: Dictionary[int, Color] = {
	Globals.MaskColors.BLUEMASK: Color.BLUE,
	Globals.MaskColors.REDMASK: Color.RED,
	Globals.MaskColors.YELLOWMASK: Color.YELLOW
}


const SPEED = 100.0
const FRICTION = 30.0
var x_direction: int
var target: CharacterBody2D
var knockback_impulse: float
var hit_points: int = 2

@onready var left_edge_detector: RayCast2D = %LeftEdgeDetector
@onready var right_edge_detector: RayCast2D = %RightEdgeDetector
@onready var hit_particles: GPUParticles2D = %HitParticles
@export var visual: CanvasItem



func _enter_tree() -> void:
	#for i in range(Globals.MaskColors.BLUEMASK, Globals.MaskColors.YELLOWMASK + 1):
	#	set_collision_layer_value(enemy_color, false)	
	set_collision_layer_value(enemy_color, true)
	SignalBus.player_picked_up_mask.connect(_alter_target)
	visual.modulate = mask_color_modulate[ enemy_color ]
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	hit_particles.modulate = mask_color_modulate[ enemy_color ]
	print(self, "\n\tcollision layer for ", enemy_color, " is ", get_collision_layer_value(enemy_color))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if target != null and is_zero_approx(knockback_impulse):
		x_direction = 1 if (global_position.x - target.global_position.x < 0.0) else -1

		if x_direction == 1 and right_edge_detector.is_colliding():
			self.velocity.x = x_direction * SPEED * delta * 60
		elif x_direction == -1 and left_edge_detector.is_colliding():
			self.velocity.x = x_direction * SPEED * delta * 60
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif not is_zero_approx(knockback_impulse):
		velocity.x = knockback_impulse * delta * 60
		velocity.y = -abs(knockback_impulse) * delta * 60

		knockback_impulse = move_toward(knockback_impulse, 0, FRICTION)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()



func _alter_target(player_color: int) -> void:
	if player_color == enemy_color:
		target = null
	else:
		target = get_tree().get_first_node_in_group("player")


func take_knockback(direction_sign: int) -> void:
	hit_particles.emitting = true
	knockback_impulse = 300 * direction_sign
	hit_points -= 1
	if hit_points <= 0:
		_die()


func _die() -> void:
	get_parent().remove_child(self)
	queue_free()
