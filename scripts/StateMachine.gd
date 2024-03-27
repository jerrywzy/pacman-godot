extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

# for each child State node, add to dictionary
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state	
	
# call update and physics update for respective states
func _process(delta):
	# if there is a current_state
	if current_state:  
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)
	
func on_child_transition(state, new_state_name):
	if state != current_state:  # make sure new state is not already current state (covers overwriting)
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:  # make sure new state is specified
		return
	
	if current_state:
		current_state.exit()
				
	new_state.enter()
	current_state = new_state # update current_state for physics
	
func change_state(new_state_name):  # manual state change
	var new_state = states.get(new_state_name.to_lower())
	if current_state:
		current_state.exit()
				
	new_state.enter()
	current_state = new_state # update current_state for physics
		
		
