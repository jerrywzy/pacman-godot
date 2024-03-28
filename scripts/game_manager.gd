extends Node

signal global_scatter_timer_timeout
signal global_begin_scatter
signal global_stop_scatter
signal global_cowardly_clyde
signal global_scatter_ending
signal global_ghost_eaten
signal global_begin_retreat
signal global_retreat_finished

@onready var scatter_timer = $ScatterTimer
@onready var scatter_flash_timer = $ScatterFlashTimer
@onready var player = get_node("/root/Level/Pacman")
@onready var clyde = get_node("/root/Level/Clyde")
@onready var blinky = get_node("/root/Level/Blinky")
@onready var inky = get_node("/root/Level/Inky")
@onready var pinky = get_node("/root/Level/Pinky")
@onready var clyde_retreat = get_node("/root/Level/Clyde/StateMachine/GhostRetreat")
@onready var blinky_retreat = get_node("/root/Level/Blinky/StateMachine/GhostRetreat")
@onready var pinky_retreat = get_node("/root/Level/Pinky/StateMachine/GhostRetreat")
@onready var inky_retreat = get_node("/root/Level/Inky/StateMachine/GhostRetreat")
var pacman_is_powered: bool = false
var clyde_activated: bool = false
var lives: int = 3
var recorded_score: int = 0

func _ready():
	connect_signals()
	
func connect_signals():
	clyde.clyde_coward.connect(emit_cowardly_clyde)
	player.ghost_eaten.connect(begin_retreat.bind())
	player.power_pellet_eaten.connect(begin_scatter)
	player.small_pellet_eaten.connect(add_to_score)
	player.power_pellet_eaten.connect(add_to_score)
	clyde_retreat.retreat_finished.connect(send_checking_score_reset_signal)
	blinky_retreat.retreat_finished.connect(send_checking_score_reset_signal)
	pinky_retreat.retreat_finished.connect(send_checking_score_reset_signal)
	inky_retreat.retreat_finished.connect(send_checking_score_reset_signal)
	
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

func send_checking_score_reset_signal():
	global_retreat_finished.emit()
	
func add_to_score():
	recorded_score += 1
