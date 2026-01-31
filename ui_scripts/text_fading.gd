extends Node

var alphaChange = -0.03

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_color: Color
	current_color = self.label_settings.font_color
	var new_color: Color
	new_color = Color(current_color, current_color.a + alphaChange)
	
	self.label_settings.font_color = new_color
	
	if (new_color.a <= 0) || (new_color.a >= 1):
		alphaChange *= -1

	pass
