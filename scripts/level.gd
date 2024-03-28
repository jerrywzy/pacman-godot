extends Node2D

signal ghosts_start_chase
signal clyde_start_chase
signal inky_start_chase
signal scatter_ghosts

var checking_score: int = 0
var total_score: int = 0
var power_pellet_score: int = 0
var level_initialized: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	AudioManager.pacman_start.play()
	await AudioManager.pacman_start.finished
	get_tree().paused = false
	$Pacman.small_pellet_eaten.connect(update_score)
	$Pacman.power_pellet_eaten.connect(update_power_pellet_count)
	$Pacman.pacman_died.connect(lose_game)
	GameManager.global_begin_retreat.connect(update_ghost_score.bind())
	GameManager.global_stop_scatter.connect(reset_score_baseline)
	GameManager.global_retreat_finished.connect(reset_score_baseline)
	$WinScreen.hide()
	$LoseScreen.hide()
	GameManager.lives = 3
	level_initialized = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if level_initialized:
		GameManager.connect_signals()
		level_initialized = false
	if checking_score >= 10:  
		ghosts_start_chase.emit()
	if checking_score >= 30:  
		inky_start_chase.emit()
	if power_pellet_score >= 3:
		clyde_start_chase.emit()
	update_ui()
	check_win()
	
func update_ui():
	$UI/Lives.text = "Lives: "
	match GameManager.lives:
		3:
			$UI/TextureRect.modulate = Color("ffffff")
			$UI/TextureRect2.modulate = Color("ffffff")
			$UI/TextureRect3.modulate = Color("ffffff")
		2:
			$UI/TextureRect.modulate = Color("ffffff")
			$UI/TextureRect2.modulate = Color("ffffff")
			$UI/TextureRect3.modulate = Color("000000")
		1:
			$UI/TextureRect.modulate = Color("ffffff")
			$UI/TextureRect2.modulate = Color("000000")
			$UI/TextureRect3.modulate = Color("000000")
		0:
			$UI/TextureRect.modulate = Color("000000")
			$UI/TextureRect2.modulate = Color("000000")
			$UI/TextureRect3.modulate = Color("000000")
	$UI/Score.text = "Score: " + str(total_score)

func update_score():
	checking_score += 1
	total_score += 1

func reset_score_baseline():  # reset checking_score to 0 to start chase again
	checking_score = 0

func update_power_pellet_count():
	power_pellet_score += 1
	total_score += 10
	
func update_ghost_score(placeholder):
	total_score += 50
	
func check_win():
	if GameManager.recorded_score == 408:
		get_tree().paused = true
		$WinScreen.show()
		
func lose_game():
	get_tree().paused = true
	$LoseScreen.show()

func reset_level():
	for i in get_tree().get_nodes_in_group("PowerPellets"):
		i.show()
		var collision_shape_2d = str(get_path_to(i)) + "/CollisionShape2D"
		get_node(collision_shape_2d).set_deferred("disabled", false)
	for i in get_tree().get_nodes_in_group("SmallPellets"):
		i.show()
		var collision_shape_2d = str(get_path_to(i)) + "/CollisionShape2D"
		get_node(collision_shape_2d).set_deferred("disabled", false)
	for i in get_tree().get_nodes_in_group("Enemy"):
		i.global_position = Vector2(12, 36)
		var state_machine = str(get_path_to(i)) + "/StateMachine"
		get_node(state_machine).change_state("GhostIdle")
	$WinScreen.hide()
	$LoseScreen.hide()
	GameManager.lives = 3
	GameManager.recorded_score = 0
	$Pacman.reset()
	checking_score = 0
	total_score = 0
	power_pellet_score = 0
	AudioManager.pacman_start.play()
	await AudioManager.pacman_start.finished
	get_tree().paused = false
