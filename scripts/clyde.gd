extends Area2D

signal clyde_chill
signal clyde_coward

@onready var player = $"../Pacman"
@onready var StateMachine = $StateMachine
var position_diff: Vector2
var distance: float

# Called when the node enters the scene tree for the first time.
func _ready():
	clyde_chill.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var position_diff = player.global_position - global_position
	var distance = position_diff.length()
	if distance < 200:  
		clyde_coward.emit()


