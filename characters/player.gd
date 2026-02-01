extends CharacterBody2D
class_name Player


const SPEED = 140.0
const SPRINTSPEED = 240.0
const JUMP_VELOCITY = -400.0
const ACCEL = 30.0

@onready var mask_pickup_area: Area2D = %MaskPickupRange
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hitbox: Area2D = %MeleeHitbox
@onready var invuln_timer: Timer = %InvulnTimer

var player_mask: int
var mask_color_modulate: Dictionary[int, Color] = {
	Globals.MaskColors.UNMASKED: Color.GRAY,
	Globals.MaskColors.BLUEMASK: Color.BLUE,
	Globals.MaskColors.REDMASK: Color.RED,
	Globals.MaskColors.YELLOWMASK: Color.YELLOW
}
var hit_points: int = 3

func _ready() -> void:
	print(self, " ready!")
	mask_pickup_area.area_entered.connect(_on_mask_pickup)
	hitbox.body_entered.connect(damage_enemy)
	invuln_timer.timeout.connect( func() -> void:
		_toggle_enemy_collisions( true )
	)
	


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		animation_player.queue("run")
		velocity.x += direction * ACCEL
		
		if Input.is_action_pressed("sprint"):
			velocity.x = clampf(velocity.x, -SPRINTSPEED, SPRINTSPEED)
		else:
			velocity.x = clampf(velocity.x, -SPEED, SPEED)
	else:
		if animation_player.current_animation == "run":
			animation_player.stop()
		velocity.x = move_toward(velocity.x, 0, ACCEL)
	
	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider.is_in_group("enemy"):
			print("hit an enemy")
			_take_hit()
			break





func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		animation_player.play("turn_left")
	elif event.is_action_pressed("move_right"):
		animation_player.play("turn_right")
	

	if event.is_action_pressed("melee"):
		animation_player.play("attack")
		velocity.x = move_toward(velocity.x, 0, ACCEL * 2)
	
	if event.is_action_released("melee"):
		animation_player.play("interrupt_melee")


func _on_mask_pickup(body: Area2D) -> void:
	if body is Mask:
		print(self, "picked up a mask!")
		modulate = mask_color_modulate[ body.mask_color ]
		SignalBus.player_picked_up_mask.emit( body.mask_color )
		body.player_picked_me_up()


func damage_enemy(body: Node2D):
	if body is CharacterBody2D and body is not Player:
		if body.get_collision_layer_value(Globals.MaskColors.BLUEMASK):
			print("impacted ", body)


func _take_hit() -> void:
	print("hit taken")
	hit_points -= 1
	SignalBus.player_damaged.emit(hit_points)
	invuln_timer.start()
	_toggle_enemy_collisions( false )
	if hit_points <= 0:
		print("u ded!")
		SignalBus.player_died.emit()
		hit_points = 3


func _toggle_enemy_collisions(status: bool) -> void:
	print("toggling invincibility")
	modulate.a = 1.0 if status else 0.5
	for layer in range(Globals.MaskColors.BLUEMASK, Globals.MaskColors.YELLOWMASK + 1):
		set_collision_mask_value( layer, status )
