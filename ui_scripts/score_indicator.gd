extends Label

var score: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	SignalBus.enemy_killed.connect(_get_points)

func _get_points():
	score += 1
	_update_label_text()
	
func _update_label_text():
	self.text = str(score)
