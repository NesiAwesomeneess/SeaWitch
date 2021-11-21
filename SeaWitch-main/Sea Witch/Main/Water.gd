extends Area2D

export (NodePath) var camera_path
onready var camera : Camera2D = get_node(camera_path)

var sea_level = 90

func _ready():
	global_position = camera.get_camera_screen_center()
	
	#This keeps the sea at sea_level
	global_position.y = max(global_position.y, sea_level)

func _process(_delta):
	global_position = camera.get_camera_screen_center()
	global_position.y = max(global_position.y, sea_level)
