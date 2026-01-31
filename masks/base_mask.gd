extends Area2D
class_name Mask

var mask_color: int = 0
@export var mask_textures: Array[Texture2D]
@onready var mask_sprite: Sprite2D = %MaskSprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#mask_sprite.texture = mask_textures[ mask_color ]


func player_picked_me_up() -> void:
	get_parent().remove_child(self)
	call_deferred("queue_free")
