extends Node

signal global_scatter_timer_timeout
signal global_begin_scatter
signal global_stop_scatter
signal global_cowardly_clyde
signal global_scatter_ending
signal global_ghost_eaten
signal global_begin_retreat

@onready var scatter_timer = $ScatterTimer
@onready var scatter_flash_timer = $ScatterFlashTimer
@onready var player = get_node("/root/Level/Pacman")
@onready var clyde = get_node("/root/Level/Clyde")
var pacman_is_powered: bool = false
var clyde_activated: bool = false
var lives: int = 3

func _ready():
	clyde.clyde_coward.connect(emit_cowardly_clyde)
	player.ghost_eaten.connect(begin_retreat.bind())
	player.power_pellet_eaten.connect(begin_scatter)
	
func begin_scatter():
	pacman_is_powered = true
	scatter_timer.start()
	scatter_flash_timer.start()
	global_begin_scatter.emit()

func _on_scatter_timer_timeout():
	pacman_is_powered = false
	global_stop_scatter.emit()

func emit_cowardly_clyde():
	global_cowardly_clyde.emit()

func _on_scatter_flash_timer_timeout():
	global_scatter_ending.emit()

func begin_retreat(ghost_name):
	global_begin_retreat.emit(ghost_name)
