#Author: Muhammad Fiqri
#License: Open Source
#Note: For Tutorial
extends KinematicBody2D

#the PathfindingServer require 3 node. 
#1. The agent which is used for the User Pathfinding (object that move according to path)
#2. The Navigation node which hold the polygonmesh of the Navigation (place where agent can move)
#3. The Navigation2DServer, for handling several pathfinding of different agent (The Calculator)
#the line is only for debugging

onready var nav = get_tree().get_root().get_node("test/Navigation2D")
onready var nav_agent = $NavigationAgent2D
onready var line = get_tree().get_root().get_node("test/Line2D")

var path = []
var velocity = Vector2.ZERO

func _ready():
#	it set the navigation polygon mesh for navigation agent
	nav_agent.set_navigation(nav)

func _physics_process(delta):
#	when mouse clicked create a path to follow from agent to mouse position
	if Input.is_mouse_button_pressed(1):
		init_path()
	
#	when the path has a points, move to the first point
	if path.size() > 0:
		move_to_path()

#the function is used to create a path from character agent position to mouse position
#the map_get_path require 3 argument the RID of the navigation map, the char agent position, and the target. the false or true dictate if the path is optimized or not.
#the first point of the path is removed because it's usually the starting position
#and than the line is drawn according to the path
func init_path():
	var target = get_global_mouse_position()
	var char_pos = global_position
	path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(),char_pos,target,false)
	path.remove(0)
	line.points = path
	navigate()

#if the path has points, set the first movement target to the first point
func navigate():
	if path.size() > 0:
		nav_agent.set_target_location(path[0])

#target are the next location of agent to move
#set the velocity of agent to the direction of the target
#and set the velocity
#and if the position of the agent reached the target point remove the point and update the path
#and set the next location by the first point
func move_to_path():
	var current_pos = global_position
	var target = nav_agent.get_next_location()
	velocity = current_pos.direction_to(target) * 1000
	nav_agent.set_velocity(velocity)
	if current_pos.distance_to(target) < 1:
		path.remove(0)
		line.points = path
		if path.size():
			nav_agent.set_target_location(path[0])

#this function is called when set_velocity function is calculated and return a safe velocity
#this velocity is the safe velocity to be used so the agent doesn't over passed the point
func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	var velocity = move_and_slide(safe_velocity)
