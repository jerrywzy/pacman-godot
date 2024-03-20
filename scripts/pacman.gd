extends CharacterBody2D


var speed = 100.0
var direction

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity = direction * speed

	move_and_slide()

func _input(event):
	if event.is_action_pressed("left"):
		direction = Vector2.LEFT
	if event.is_action_pressed("right"):
		direction = Vector2.RIGHT
	if event.is_action_pressed("up"):
		direction = Vector2.UP
	if event.is_action_pressed("down"):
		direction = Vector2.DOWN
