extends Node

const TARGET_VOLUME = -10 ## Target volume for playing
const TARGET_MUTE_VOLUME = -80 ## Target volume for muted tracks
const FADE_RATE = 5.0

class AudioPlayer:
	var color: int
	var stream: AudioStreamPlayer
	var state: AudioPlayerState
	func _init(ap_color: int):
		color = ap_color
		state = AudioPlayerState.STOPPED

enum AudioPlayerState {
	PLAYING,
	FADING_IN,
	FADING_OUT,
	STOPPED
}

var audioPlayers = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_picked_up_mask.connect(_on_mask_pickup)
	_create_audio_players()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for audioPlayer in audioPlayers.values():
		match audioPlayer.state:
			AudioPlayerState.FADING_IN:
				if audioPlayer.stream.volume_db < TARGET_VOLUME:
					audioPlayer.stream.volume_db += delta*FADE_RATE
				if audioPlayer.stream.volume_db >= TARGET_VOLUME:
					audioPlayer.stream.volume_db = TARGET_VOLUME
					audioPlayer.state = AudioPlayerState.PLAYING
			AudioPlayerState.FADING_OUT:
				if audioPlayer.stream.volume_db > TARGET_MUTE_VOLUME:
					audioPlayer.stream.volume_db -= delta*FADE_RATE
				if audioPlayer.stream.volume_db <= TARGET_MUTE_VOLUME:
					audioPlayer.stream.volume_db = TARGET_MUTE_VOLUME
					audioPlayer.stream.stop()
					audioPlayer.state = AudioPlayerState.STOPPED

func _on_mask_pickup(maskColor: int):
	# Check if audioPlayer related to this maskColor is either fading_out or stopped:
	if (audioPlayers[maskColor].state == AudioPlayerState.STOPPED):
		audioPlayers[maskColor].stream.play()
		audioPlayers[maskColor].state = AudioPlayerState.FADING_IN
	elif (audioPlayers[maskColor].state == AudioPlayerState.FADING_OUT):
		audioPlayers[maskColor].state = AudioPlayerState.FADING_IN
	else:
		# The stream related to this color is already fading in or playing, so we don't do anything special.
		pass
	# No matter the condition of the stream related to the picked up mask, we now have to mark all other streams as fading_out if they aren't already stopped or fading out.
	for audioPlayer in audioPlayers.values():
		if audioPlayer.color != maskColor:
			if audioPlayer.state == AudioPlayerState.PLAYING || audioPlayer.state == AudioPlayerState.FADING_IN:
				audioPlayer.state = AudioPlayerState.FADING_OUT
	
func _clean_up_streams():
	pass
	
func _create_audio_players():
	audioPlayers[Globals.MaskColors.UNMASKED] = AudioPlayer.new(Globals.MaskColors.UNMASKED)
	audioPlayers[Globals.MaskColors.UNMASKED].stream = get_node("BaseMusicSource")
	audioPlayers[Globals.MaskColors.UNMASKED].state = AudioPlayerState.PLAYING
	audioPlayers[Globals.MaskColors.BLUEMASK] = AudioPlayer.new(Globals.MaskColors.BLUEMASK)
	audioPlayers[Globals.MaskColors.BLUEMASK].stream = get_node("BlueMaskMusicSource")
	audioPlayers[Globals.MaskColors.GREENMASK] = AudioPlayer.new(Globals.MaskColors.GREENMASK)
	audioPlayers[Globals.MaskColors.GREENMASK].stream = get_node("GreenMaskMusicSource")
	audioPlayers[Globals.MaskColors.REDMASK] = AudioPlayer.new(Globals.MaskColors.REDMASK)
	audioPlayers[Globals.MaskColors.REDMASK].stream = get_node("RedMaskMusicSource")
