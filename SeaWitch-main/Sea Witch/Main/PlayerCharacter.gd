extends KinematicBody2D

onready var skin = $Skin
onready var camera = $Cam

const GRAVITY = 200
const BUOYANCY_FORCE = 3
const VISCOSITY = 2
const UPTHRUST = -200

const WIND_RESISTANCE = 2

const MAX_UNDERWATER_SPEED = 100
const MAX_AIR_SPEED = 80

var velocity = Vector2.DOWN * GRAVITY
var speed = 140

enum states {IN_AIR, SINKING, SUNK, RISING}
var state = states.IN_AIR

func _physics_process(delta):
	var direction = get_input()
	
	velocity += get_velocity(direction) * delta
	
	match state:
		states.IN_AIR:
			velocity.x = clamp(velocity.x, -MAX_AIR_SPEED, MAX_AIR_SPEED)
			if is_in_water():
				change_state(states.SINKING)
		states.SINKING:
			velocity.x = clamp(velocity.x, -MAX_UNDERWATER_SPEED, MAX_UNDERWATER_SPEED)
			if direction.x == 0:
				velocity.x = lerp(velocity.x, 0, VISCOSITY * delta)
			velocity.y = lerp(velocity.y, 0, (VISCOSITY/2) * delta)
			
			if velocity.y <= 10:
				change_state(states.SUNK)
		states.SUNK:
			velocity.x = clamp(velocity.x, -MAX_UNDERWATER_SPEED, MAX_UNDERWATER_SPEED)
			velocity.y = clamp(velocity.y, -MAX_UNDERWATER_SPEED, MAX_UNDERWATER_SPEED)
			
			if direction.x == 0:
				velocity.x = lerp(velocity.x, 0, VISCOSITY * delta)
			if direction.y == 0:
				velocity.y = lerp(velocity.y, 0, VISCOSITY * delta)
			
			if !is_in_water():
				change_state(states.IN_AIR)
		states.RISING:
			velocity.y = UPTHRUST
			velocity.x = clamp(velocity.x, -MAX_UNDERWATER_SPEED, MAX_UNDERWATER_SPEED)
			
			if direction.x == 0:
				velocity.x = lerp(velocity.x, 0, VISCOSITY * delta)
			
			if !is_in_water():
				change_state(states.IN_AIR)
	velocity = move_and_slide(velocity)

func get_velocity(input_direction):
	var desired_velocity = Vector2()
	
	desired_velocity = input_direction * speed
	
	if !is_in_water():
		desired_velocity.y += GRAVITY
	
	return desired_velocity

func get_input():
	var input_direction = Vector2((Input.get_action_strength("Right")-Input.get_action_strength("Left")), 
								  (Input.get_action_strength("Down")-Input.get_action_strength("Up")))
	
	return input_direction

func _input(event):
	if Input.is_action_just_pressed("Rise"):
		change_state(states.RISING)

func change_state(new_state):
	state = new_state

func is_in_water():
	return skin.get_overlapping_areas().size() > 0
