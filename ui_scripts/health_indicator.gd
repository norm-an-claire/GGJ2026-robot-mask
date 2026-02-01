extends Node

var sprites = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_damaged.connect(_on_player_damaged) 
	_load_health_sprites()

func _load_health_sprites():
	sprites = {
		"full_health": load("res://assets/ui_assets/full_health_base.png"),
		"medium_health": load("res://assets/ui_assets/medium_health_base.png"),
		"low_health": load("res://assets/ui_assets/low_health_base.png")
	}
	
func _on_player_damaged(currHitPoints: int):
	print("in _on_player_damaged")
	# Add code to swap the sprite for the health based on the incoming
	# current amount
	match currHitPoints:
		3:
			# Set sprite to full_health_base
			self.texture = sprites["full_health"]
		2:
			# Set sprite to medium_health_base
			self.texture = sprites["medium_health"]
		1:
			# Set sprite to low_health_base
			self.texture = sprites["low_health"]
		0: 
			# This shouldn't ever matter, but keep it to low_health
			self.texture = sprites["low_health"]
		_:
			pass
