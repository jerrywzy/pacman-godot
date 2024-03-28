extends State
class_name GhostIdle

@onready var level = $"../../.."
@export var enemy: Area2D
@onready var ghost_name = $"../..".name

# Called when the node enters the scene tree for the first time.
func enter():
	match ghost_name:
		"Blinky":
			level.ghosts_start_chase.connect(start_chase)
		"Pinky":
			level.ghosts_start_chase.connect(start_chase)
		"Inky":
			level.inky_start_chase.connect(start_chase)
		"Clyde":
			level.clyde_start_chase.connect(start_chase)
			if GameManager.clyde_activated:
				Transitioned.emit(self, "GhostChase")  # immediately chase again if Clyde and is activated 

func start_chase():
	Transitioned.emit(self, "GhostChase")
