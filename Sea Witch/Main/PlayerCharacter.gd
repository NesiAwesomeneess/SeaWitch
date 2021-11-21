extends KinematicBody2D

onready var skin = $Skin
onready var camera = $Cam

const GRAVITY = 200
const VISCOSITY = 2
const UPTHRUST = -200

const WIND_RESISTANCE = 2
const MAX_SPEED = 300

var velocity = Vector2.DOWN * GRAVITY
var speed = 140
var rising = false

enum states {IN_AIR, SINKING, SUNK, RISING}
var state = states.IN_AIR

func _process(delta):
	print(position)

func _physics_process(delta):
	velocity += get_velocity(get_input()) * delta
	
	match state:
		states.IN_AIR:
			velocity.x = lerp(velocity.x, 0, WIND_RESISTANCE * delta)
			if is_in_water():
				change_state(states.SINKING)
		states.SINKING:
			velocity.x = lerp(velocity.x, 0, VISCOSITY * delta)
			velocity.y = lerp(velocity.y, 0, (VISCOSITY/2) * delta)
			
			if velocity.y <= 10:
				change_state(states.SUNK)
		states.SUNK:
			velocity = lerp(velocity, Vector2(), VISCOSITY * delta)
			
			if !is_in_water():
				change_state(states.IN_AIR)
		states.RISING:
			velocity.y = UPTHRUST
			velocity.x = lerp(velocity.x, 0, VISCOSITY * delta)
			
			if !is_in_water():
				change_state(states.IN_AIR)
	
	if is_in_water():
		if rising:
			velocity.y = UPTHRUST
		else:
			velocity.x = lerp(velocity.x, 0, VISCOSITY * delta)
	else:
		rising = false
		velocity.x = lerp(velocity.x, 0, WIND_RESISTANCE * delta)
	
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
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
