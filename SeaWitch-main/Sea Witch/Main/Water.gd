extends Area2D

export (NodePath) var camera_path
onready var camera : Camera2D = get_node(camera_path)

export (PackedScene) var trash_scene
var max_trash_count = 20
onready var trash_node = $TrashNode

var sea_level = 90

func _ready():
	global_position = camera.get_camera_screen_center()
	
	#This keeps the sea at sea_level
	global_position.y = max(global_position.y, sea_level)

func _process(_delta):
	global_position = camera.get_camera_screen_center()
	global_position.y = max(global_position.y, sea_level)
	
	for _trash in (max_trash_count - trash_node.get_child_count()):
		var trash = trash_scene.instance()
		var spawn_direction = (pow(-1, randi() % 2))
		trash.global_position = global_position + (Vector2(rand_range(160, 0) * spawn_direction, rand_range(-10, 240)) + Vector2(120 * spawn_direction, 0))
		trash.set_as_toplevel(true)
		
		trash_node.add_child(trash)

func Player_change_level(level_index):
	pass # Replace with function body.
