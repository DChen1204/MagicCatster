
class_name Character
extends Node2D

# Base class of all characters

# Base attack
var attack: float

# Base defense
var defense: float

# Base health
var health: float

# True if controlled by the player
var is_play_character: bool

# SP (applicable when controlled by player)
var sp: int = 0

# whether the character is shielding
var shielded: bool

signal sp_changed(new_sp: int)
signal shield_changed(new_shield: bool)

# Assign stats
func assign_stats(att: float, def: float, hp: float, is_play: bool, new_sp: int = 0):
	attack = att
	defense = def
	health = hp
	is_play_character = is_play
	sp = new_sp
