extends State
class_name GhostScatter

@onready var tilemap: TileMap = $"../../../TileMap"
@onready var player = $"../../../Pacman"
@onready var ghost_name = $"../..".name
@onready var ghost = $"../.."
@export var enemy: Area2D
@export var ghost_sprite: Sprite2D
@export var eye_sprite: Sprite2D
@export var target_scatter_position: Vector2
var ghost_pen_position: Vector2 = Vector2(0, 30)
var is_moving: bool
var astar_grid: AStarGrid2D
var scatter_timer: Timer
@onready var initial_color: Color = ghost_sprite.modulate
var is_scattering: bool = false
var blue_scatter_color: Color = Color("0011ff")

func enter():
	is_scattering = true
	GameManager.global_stop_scatter.connect(on_scatter_timer_timeout)
	GameManager.global_scatter_ending.connect(scatter_ending_flash)
	GameManager.global_begin_retreat.connect(retreat_ghost.bind())
	# change the ghost color
	ghost_sprite.modulate = blue_scatter_color
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

func exit():
	is_scattering = false
	ghost_sprite.modulate = initial_color

func Update(_delta):
	if is_moving:
		return
	elif not is_moving:
		set_target(target_scatter_position)
		calc_move()
	
func set_target(target_pos):
	target_scatter_position = target_pos

func calc_move():
	# path is IDs of points from globalpos to playerglobalpos
	# create astar path from enemy to target_position (converted to tilemap ID)
	var path = astar_grid.get_id_path(
		tilemap.local_to_map((enemy.global_position)),
		tilemap.local_to_map(target_scatter_position)
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
		
func retreat_ghost(ghost_to_retreat):
	if ghost_to_retreat == ghost_name:
		ghost_sprite.modulate = initial_color
		Transitioned.emit(self, "GhostRetreat")

func on_scatter_timer_timeout():
	ghost_sprite.modulate = initial_color
	Transitioned.emit(self, "GhostChase")

func scatter_ending_flash():
	if is_scattering:
		var tween = get_tree().create_tween()
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", blue_scatter_color, 0.1)
		tween.tween_property(ghost_sprite, "modulate", Color.WHITE, 0.1)
		tween.tween_property(ghost_sprite, "modulate", initial_color, 0.1)
