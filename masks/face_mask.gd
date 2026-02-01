extends Mask

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mask_color = 0
	animated_sprite = %AnimatedSprite2D
	animated_sprite.play("pickup")




func player_picked_me_up() -> void:
	get_parent().remove_child(self)
	call_deferred("queue_free")