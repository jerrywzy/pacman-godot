extends CharacterBody2D
class_name Player

@export var speed := 175
@export var current_dir = "none"
@export var movement_direction := Vector2.ZERO
var movement_enabled = true
var vel := Vector2()
var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}

func get_input():
	if movement_enabled:
		vel = Vector2()
		for input in inputs:
			if Input.is_action_just_pressed(input):
				current_dir = input
				movement_direction = inputs[input]
				animate_movement()
		
		vel = movement_direction * speed


func animate_movement():
	#$Sprite2D.play("eating")
	match current_dir:
		"right":
			$AnimatedSprite2D.rotation_degrees = 0
			$AnimatedSprite2D.flip_h = false
		"left":
			$AnimatedSprite2D.rotation_degrees = 0
			$AnimatedSprite2D.flip_h = true
		"up":
			$AnimatedSprite2D.rotation_degrees = -90
			$AnimatedSprite2D.flip_h = false
		"down":
			$AnimatedSprite2D.rotation_degrees = 90
			$AnimatedSprite2D.flip_h = false

func _physics_process(_delta):
	if !movement_enabled:
		return
	
	get_input()
	set_velocity(vel)
	move_and_slide()
	vel = vel
	if vel.length() < 1 and movement_direction != Vector2.ZERO:
		movement_direction = Vector2.ZERO
		current_dir = "none"
		#$Sprite2D.playing = false


func warp_to(pos):
	global_position = pos


#func reset():
	#if $Sprite2D.is_connected("animation_finished", Callable(self, "reset")):
		#$Sprite2D.disconnect("animation_finished", Callable(self, "reset"))
	#position = Vector2(264, 212)
	#$Sprite2D.play("idle")
	#current_dir = "none"
	#movement_direction = Vector2.ZERO
	#emit_signal("player_reset")

