extends CharacterBody2D
class_name FlyingEnemy


const SPEED = 50.0
const FRICTION = 10.0
var x_direction: int
var y_direction: int
var target: CharacterBody2D
var knockback_impulse: float
var hit_points: int = 2

@onready var animated_sprite: AnimatedSprite2D = %Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	if target != null and is_zero_approx(knockback_impulse):
		animated_sprite.play("chase")
		y_direction = 1 if (global_position.y - target.global_position.y < 0.0) else -1
		x_direction = 1 if (global_position.x - target.global_position.x < 0.0) else -1

		if x_direction == 1:
			animated_sprite.flip_h = true
			self.velocity.x = x_direction * SPEED * delta * 60
		elif x_direction == -1:
			animated_sprite.flip_h = false
			self.velocity.x = x_direction * SPEED * delta * 60
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

		if y_direction == 1:
			self.velocity.y = y_direction * SPEED * delta * 60
		elif y_direction == -1:
			self.velocity.y = y_direction * SPEED * delta * 60
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		
	elif not is_zero_approx(knockback_impulse):
		animated_sprite.play("default")
		velocity.x = knockback_impulse * delta * 60
		velocity.y = -abs(knockback_impulse) * delta * 60

		knockback_impulse = move_toward(knockback_impulse, 0, FRICTION)
	else:
		animated_sprite.play("default")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider.is_in_group("player"):
			knockback_impulse = sign(global_position.x - collision.get_position().x) * 260
			break


func take_knockback(direction_sign: int) -> void:
	#hit_particles.emitting = true
	knockback_impulse = 300 * direction_sign
	hit_points -= 1
	if hit_points <= 0:
		_die()


func _die() -> void:
	get_parent().remove_child(self)
	queue_free()