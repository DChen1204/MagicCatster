extends Node

# This the where all buttons will get their ui sounds from

var _player := AudioStreamPlayer.new()

func _ready() -> void:
	# Change this to the path of your click sound
	_player.stream = preload("res://BSmallAudio/uiButton1.wav")
	add_child(_player)

func play_click() -> void:
	_player.play()
