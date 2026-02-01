extends Node

const TARGET_VOLUME = -10 ## Target volume for playing
const TARGET_MUTE_VOLUME = -80 ## Target volume for muted tracks
const FADE_TIME = 3.0

var currentPlayer: AudioStreamPlayer
var nextPlayer: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentPlayer = get_node("BaseMusicSource")
	SignalBus.player_picked_up_mask.connect(_on_mask_pickup)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mask_pickup(maskColor: int):
	print("AudioManager heard mask pickup")
	var tween = create_tween()
	# setup nextPlayer based on color
	match maskColor:
		Globals.MaskColors.BLUEMASK:
			nextPlayer = get_node("BlueMaskMusicSource")
		Globals.MaskColors.GREENMASK:
			nextPlayer = get_node("GreenMaskMusicSource")
		Globals.MaskColors.REDMASK:
			nextPlayer = get_node("RedMaskMusicSource")
		_:
			printerr("Unrecognized Mask Color")
	# fade targetPlayer in over 1 second to base volume
	nextPlayer.volume_db = -80
	nextPlayer.play()
	
	tween.tween_property(nextPlayer, "volume_db", TARGET_VOLUME, FADE_TIME)
	# fade currentPlayer out over 1 second to 0.
	tween.tween_property(currentPlayer, "volume_db", TARGET_MUTE_VOLUME, FADE_TIME)
	# On tween complete, callback this function
	tween.tween_callback(_clean_up_streams)
	
func _clean_up_streams():
	# Pause currentPlayer, set currentPlayer to nextPlayer and
	# set nextPlayer to void.
	currentPlayer.stop()
	currentPlayer = nextPlayer
	nextPlayer = null
