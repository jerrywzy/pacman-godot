extends CharacterBody2D

var speed = 100.0
var tile_size = 24
var current_direction = Vector2.ZERO
var target_direction = Vector2.ZERO
@onready var raycasts = $Raycasts
@onready var raycast_a = $Raycasts/RayCast2D
@onready var raycast_b = $Raycasts/RayCast2D2

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	

func _physics_process(delta):
	if target_direction:  # if there is input
		move(target_direction)  # check target direction if valid

func _input(event):
	if event.is_action_pressed("left"):
		raycasts.rotation = PI
		target_direction = Vector2.LEFT
	if event.is_action_pressed("right"):
		raycasts.rotation = 0
		target_direction = Vector2.RIGHT
	if event.is_action_pressed("up"):
		raycasts.rotation = -(PI / 2)
		target_direction = Vector2.UP
	if event.is_action_pressed("down"):
		raycasts.rotation = PI / 2
		target_direction = Vector2.DOWN

func move(target):
	if not raycast_a.is_colliding() and not raycast_b.is_colliding():
		position += target * tile_size * 0.1
	else:
		pass
