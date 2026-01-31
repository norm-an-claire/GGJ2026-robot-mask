extends CharacterBody2D
class_name Player

const SPEED = 140.0
const JUMP_VELOCITY = -400.0
const ACCEL = 30.0

@onready var mask_pickup_area: Area2D = %MaskPickupRange

var player_mask: int
var mask_color_modulate: Dictionary[int, Color] = {
	Globals.MaskColors.UNMASKED: Color.GRAY,
	Globals.MaskColors.BLUEMASK: Color.BLUE,
	Globals.MaskColors.REDMASK: Color.RED,
	Globals.MaskColors.YELLOWMASK: Color.YELLOW
}


func _ready() -> void:
	mask_pickup_area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x += direction * ACCEL
		velocity.x = clampf(velocity.x, -SPEED, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL)
	
	

	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	print("my body has been entered by ", body, "!")

	# TODO - make a Mask class/scene
	# if body is Mask:
	# 	modulate = mask_color_modulate[ body.mask_color ]
	#	SignalBus.player_picked_up_mask.emit( body.mask_color )