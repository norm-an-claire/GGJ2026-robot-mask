extends Node2D


@export_file("*.tscn") var main_menu: String


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.as_text_key_label() == "Space":
		get_tree().change_scene_to_file(main_menu)