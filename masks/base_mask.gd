extends Area2D
class_name Mask

var mask_color: int = 0
@export var mask_textures: Array[AnimatedSprite2D]

var mask_color_modulate: Dictionary[int, Color] = {
	Globals.MaskColors.BLUEMASK: Color.BLUE,
	Globals.MaskColors.REDMASK: Color.RED,
	Globals.MaskColors.YELLOWMASK: Color.YELLOW
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mask_color = [Globals.MaskColors.BLUEMASK, Globals.MaskColors.REDMASK, Globals.MaskColors.YELLOWMASK].pick_random()
	modulate = mask_color_modulate[ mask_color ]
	#mask_sprite.texture = mask_textures[ mask_color ]


func player_picked_me_up() -> void:
	get_parent().remove_child(self)
	call_deferred("queue_free")
