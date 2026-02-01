extends CharacterBody2D
class_name Player


const SPEED = 140.0
const SPRINTSPEED = 240.0
const HIGH_JUMP_VELOCITY = -400.0
const LOW_JUMP_VELOCITY = -100.0
const FALL_SPEED_CAP = 600.0
const ACCEL = 30.0

@onready var mask_pickup_area: Area2D = %MaskPickupRange
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hitbox: Area2D = %MeleeHitbox
@onready var invuln_timer: Timer = %InvulnTimer
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var mask_position: Marker2D = %MaskPosition


var knockback_impulse: float

var jump_force: float = 0.0

var player_mask: int
var mask_color_modulate: Dictionary[int, Color] = {
	Globals.MaskColors.UNMASKED: Color.GRAY,
	Globals.MaskColors.BLUEMASK: Color.BLUE,
	Globals.MaskColors.REDMASK: Color.RED,
	Globals.MaskColors.GREENMASK: Color.YELLOW
}
var hit_points: int = 3
var attacking: bool = false

func _ready() -> void:
	print(self, " ready!")
	mask_pickup_area.area_entered.connect(_on_mask_pickup)
	hitbox.body_entered.connect(damage_enemy)
	invuln_timer.timeout.connect( func() -> void:
		_toggle_enemy_collisions( true )
	)
	animation_player.animation_finished.connect( func(anim_name: StringName) -> void:
		match anim_name:
			"attack":
				attacking = false
	)
	
func _process(_delta: float) -> void:
	if animation_player.current_animation == "attack":
		if animation_player.current_animation_position >= animation_player.current_animation_length:
			animation_player.animation_finished.emit(animation_player.current_animation)
	


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	# cap fall speed
	if velocity.y > FALL_SPEED_CAP:
		velocity.y = FALL_SPEED_CAP
	elif velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = LOW_JUMP_VELOCITY
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = HIGH_JUMP_VELOCITY
	
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction and is_zero_approx(knockback_impulse):
		if not attacking:
			animation_player.play("run")
			
		velocity.x += direction * ACCEL
		
		if Input.is_action_pressed("sprint"):
			velocity.x = clampf(velocity.x, -SPRINTSPEED, SPRINTSPEED)
		else:
			velocity.x = clampf(velocity.x, -SPEED, SPEED)
	else:
		if animation_player.current_animation == "run":
			animation_player.stop()
		if is_zero_approx(knockback_impulse):
			velocity.x = move_toward(velocity.x, 0, ACCEL)
		else:
			velocity.x = knockback_impulse * delta * 60
			velocity.y = -abs(knockback_impulse) * delta * 60 * .7
			knockback_impulse = move_toward(knockback_impulse, 0, ACCEL)
	
	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider.is_in_group("enemy") and collider.enemy_color != player_mask:
			knockback_impulse = sign(global_position.x - collision.get_position().x) * 400
			print("hit an enemy")
			_take_hit()
			break





func _unhandled_input(event: InputEvent) -> void:
	if not attacking:
		if Input.is_action_pressed("move_left"):
			sprite.flip_h = true
			hitbox.get_child(0).position.x = -17
		elif Input.is_action_pressed("move_right"):
			sprite.flip_h = false
			hitbox.get_child(0).position.x = 17
	

	if event.is_action_pressed("melee") and not attacking:
		animation_player.play("attack")
		attacking = true


func _on_mask_pickup(body: Area2D) -> void:
	if body is Mask:
		print(self, "picked up a mask!")
		modulate = mask_color_modulate[ body.mask_color ]
		SignalBus.player_picked_up_mask.emit( body.mask_color )

		player_mask = body.mask_color
		# reset collision layers in case this is a new mask
		set_collision_mask_value( Globals.MaskColors.BLUEMASK, true)
		set_collision_mask_value( Globals.MaskColors.REDMASK, true)
		set_collision_mask_value( Globals.MaskColors.GREENMASK, true)

		# disable collision on the mask type that we just picked up
		set_collision_mask_value( player_mask, false )
		body.animated_sprite.duplicate()
		if mask_position.get_child_count() > 0:
			var old_mask_sprite = mask_position.get_child(0)
			mask_position.remove_child(old_mask_sprite)
			old_mask_sprite.queue_free()
		mask_position.add_child(body.animated_sprite.duplicate())
		mask_position.get_child(0).play("default")
		mask_position.get_child(0).scale = Vector2(.3, .3)

		body.player_picked_me_up()


func damage_enemy(body: Node2D):
	if body is CharacterBody2D and body is not Player:
		#if body.get_collision_layer_value(Globals.MaskColors.BLUEMASK):
		print("impacted ", body)
		if body.has_method("take_knockback"):
			body.take_knockback( sign(body.global_position.x - global_position.x) )


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
	for layer in range(Globals.MaskColors.BLUEMASK, Globals.MaskColors.GREENMASK + 1):
		set_collision_mask_value( layer, status )
