extends CharacterBody2D
class_name Player

signal ghost_eaten
signal small_pellet_eaten
signal power_pellet_eaten
signal pacman_died

@export var speed := 175
@export var current_dir = "none"
@export var movement_direction := Vector2.ZERO
var movement_enabled = true
var vel := Vector2()
var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}
var powered: bool = false
var invuln: bool = false

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
	AudioManager.pacman_chomp.play()
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
	$AnimatedSprite2D.play("default")
	if vel.length() < 1 and movement_direction != Vector2.ZERO:
		movement_direction = Vector2.ZERO
		current_dir = "none"
		AudioManager.pacman_chomp.stop()		
	
	position.x = wrapf(position.x, -340, 340)


func warp_to(pos):
	global_position = pos


func reset():
	global_position = Vector2(-11, 108)
	$AnimatedSprite2D.play("default")
	current_dir = "none"
	movement_direction = Vector2.ZERO
	movement_enabled = true
	invuln = true
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	$AnimationPlayer.play("respawn")
	await get_tree().create_timer(5).timeout
	invuln = false

func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemy"):
		if powered:
			AudioManager.pacman_eat_ghost.play()
			ghost_eaten.emit(area.name)
		else:
			if not invuln:
				die()
	if area.is_in_group("SmallPellets"):
		small_pellet_eaten.emit()
		area.hide()
		var collision_shape_2d = str(get_path_to(area)) + "/CollisionShape2D"
		get_node(collision_shape_2d).set_deferred("disabled", true)
	if area.is_in_group("PowerPellets"):
		AudioManager.pacman_eat_fruit.play()
		powered = true
		power_pellet_eaten.emit()
		area.hide()
		var collision_shape_2d = str(get_path_to(area)) + "/CollisionShape2D"
		get_node(collision_shape_2d).set_deferred("disabled", true)
		$PowerTimer.start()

func die():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	movement_enabled = false
	GameManager.lives -= 1
	$AnimatedSprite2D.play("death")
	AudioManager.pacman_death.play()
	AudioManager.pacman_chomp.stop()

func _on_power_timer_timeout():
	powered = false
	
func _on_animated_sprite_2d_animation_finished():
	if GameManager.lives == 0:
		pacman_died.emit()
	else:
		reset()
