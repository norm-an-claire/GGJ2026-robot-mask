extends Area2D


func _enter_tree() -> void:
	body_entered.connect( tp_to_top )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func tp_to_top(body: Node2D) -> void:
	body.global_position.y =0
