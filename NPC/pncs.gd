#pncs pretty non controllable shithead
extends KinematicBody

const MAX_SPEED = 3
const JUMP_SPEED = 5
const ACCELERATION = 2
const DECELERATION = 4
export(NodePath) var cry_path = "Head/Tears"
var has_walked = false
var cried = false
onready var crier: Spatial = get_node(cry_path)
onready var gravity = 30
onready var start_position = translation
var velocity: Vector3
var direction: Vector3


func _physics_process(delta):
	var dir = Vector3()
	dir.x = direction.x
	dir.z = direction.z

	# Limit the input to a length of 1. length_squared is faster to check.
	if dir.length_squared() > 1:
		dir /= dir.length()

	# Apply gravity.
	velocity.y -= delta * gravity

	# Using only the horizontal velocity, interpolate towards the input.
	var hvel = velocity
	hvel.y = 0

	var target = dir * MAX_SPEED
	var acceleration
	if dir.dot(hvel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	hvel = hvel.linear_interpolate(target, acceleration * delta)

	# Assign hvel's values back to velocity, and then move.
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity = move_and_slide(velocity, Vector3.UP)

	# Jumping code. is_on_floor() must come after move_and_slide().
		
func adjust_dir(x,z):
	direction.x = x
	direction.z = z
