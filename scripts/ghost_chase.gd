extends State
class_name GhostChase

@onready var level = $"../../.."
@onready var ghost_name = $"../..".name
@onready var tilemap: TileMap = $"../../../TileMap"
@onready var player = $"../../../Pacman"
@export var enemy: Area2D
@export var ghost_sprite: Sprite2D
@export var eye_sprite: Sprite2D
var target_global_position: Vector2
var is_moving: bool
var astar_grid: AStarGrid2D
var clyde_is_scared: bool = false

func enter():
	if ghost_name == "Clyde":
		GameManager.clyde_activated = true
	GameManager.global_begin_scatter.connect(scatter)
	GameManager.global_cowardly_clyde.connect(scare_clyde)
	GameManager.global_begin_retreat.connect(retreat_ghost.bind())
	# initialize astar grid, from Retrobright's tutorial
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tilemap.get_used_rect()  # set astar grid region to tilemap_rect

	# tile cell size
	astar_grid.cell_size = Vector2(24,24)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	var region_size = astar_grid.region.size
	var region_position = astar_grid.region.position
	
	# iterate over all tiles for non walkable tiles (walls)
	for i in region_size.x:
		for j in region_size.y:
			var tile_pos = Vector2i(i + region_position.x, j + region_position.y)  # tile coordinates
			var tile_data = tilemap.get_cell_tile_data(0, tile_pos)  # data at layer 0, coordinate coords
			if tile_data == null or tile_data.get_custom_data('type') == 'wall':  # if is a custom type wall
				astar_grid.set_point_solid(tile_pos)  # disable for pathfinding


func Update(_delta):
	if is_moving:
		return
	elif not is_moving:
		match ghost_name:
			"Blinky":
				set_target(player.global_position)
			"Pinky":
				set_target(player.global_position + (player.movement_direction * 96))
			"Inky":
				set_target(player.global_position)
			"Clyde":
				if clyde_is_scared:
					set_target(Vector2(300, 400))
					if enemy.global_position == Vector2(300,396):
						clyde_is_scared = false
				elif not clyde_is_scared:
					set_target(player.global_position)
		calc_move()
	
func set_target(global_pos: Vector2):  # use this to set inheriting ghost's target global position
	target_global_position = global_pos

func calc_move():
	# path is IDs of points from globalpos to playerglobalpos
	# create astar path from enemy to target_position (converted to tilemap ID)
	var path = astar_grid.get_id_path(
		tilemap.local_to_map((enemy.global_position)),
		tilemap.local_to_map(target_global_position)
	)
	# [(0, 1), (-1, 1), (-1, 0), (-1, -1), (-1, -2), (-2, -2), (-3, -2), (-4, -2), (-5, -2), (-5, -1), (-5, 0), (-5, 1)]

	path.pop_front() # remove first item in array as it is the origin
	
	if path.is_empty(): # ended or no path found
		return
	
	var original_position = enemy.global_position  # store current pos
	enemy.global_position = tilemap.map_to_local(path[0])  # move node to current first ID in path (tilemap coords to local pos)
	ghost_sprite.global_position = original_position  # fix sprite in original position to simulate grid movement
	eye_sprite.global_position = original_position
	
	is_moving = true

func Physics_Update(delta):
	if is_moving:
		ghost_sprite.global_position = ghost_sprite.global_position.move_toward(enemy.global_position, 1)  # move sprite to global_position at speed of 1 unit per second
		eye_sprite.global_position = eye_sprite.global_position.move_toward(enemy.global_position, 1)  # move sprite to global_position at speed of 1 unit per second
		
		if ghost_sprite.global_position != enemy.global_position:  # if not arrived, return
			return
		
		is_moving = false  # else if arrived, no longer moving

func scatter():
	Transitioned.emit(self, "GhostScatter")

func scare_clyde():
	clyde_is_scared = true
	
func retreat_ghost(ghost_to_retreat):
	if ghost_to_retreat == ghost_name:
		Transitioned.emit(self, "GhostRetreat")
