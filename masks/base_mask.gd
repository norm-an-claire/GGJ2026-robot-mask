extends Area2D
class_name Mask

var mask_color: int = -1

@export var mask_textures: Array[AnimatedSprite2D]

var animated_sprite: AnimatedSprite2D

var mask_color_modulate: Dictionary[int, Color] = {
	Globals.MaskColors.BLUEMASK: Color.BLUE,
	Globals.MaskColors.REDMASK: Color.RED,
	Globals.MaskColors.GREENMASK: Color.DARK_GREEN
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(mask_textures)
	
	# TODO - take this out, replace with assignment
	if mask_color == -1:
		mask_color = [Globals.MaskColors.BLUEMASK, Globals.MaskColors.REDMASK, Globals.MaskColors.GREENMASK].pick_random()
	#modulate = mask_color_modulate[ mask_color ]
	
	animated_sprite = mask_textures[mask_color - 3]
	animated_sprite.visible = true
	animated_sprite.play("pickup")	


func player_picked_me_up() -> void:
	get_parent().remove_child(self)
	call_deferred("queue_free")
