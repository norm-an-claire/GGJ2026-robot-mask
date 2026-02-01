extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_damaged.connect(_on_player_damaged) 
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_damaged(currHitPoints: int):
	print("Hello there")
	
