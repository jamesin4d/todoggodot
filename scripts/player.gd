extends KinematicBody

const FLOOR_MAX_ANGLE: float = deg2rad(46.0)
const KEY_FORWARD: String = 'movement_forward'
const KEY_BACKWARD: String = 'movement_backward'
const KEY_LEFT: String = 'movement_left'
const KEY_RIGHT: String = 'movement_right'
const KEY_JUMP: String = 'movement_jump'
const KEY_SPRINT: String = 'movement_sprint'
const KEY_CROUCH: String = 'movement_crouch'
const KEY_INSPECT: String = 'inspect'
const STAND_HEIGHT = 0.9
const CROUCH_HEIGHT = 0.3
const CAMERA_HEIGHT_OFFSET = 0.3

# Exported (Never update this on runtime)
export(float, 0.0, 1.0, 0.05) var mouse_x_sensitivity = 0.1
export(float, 0.0, 1.0, 0.05) var mouse_y_sensitivity = 0.1
export(float, 0.0, 90.0, 0.05) var max_mouse_x_degree = 70.0

export(float, 0.0, 100.0, 0.05) var walk_speed = 5
export(float, 0.0, 100.0, 0.05) var crouch_speed = 3 #speed you move while crouched
export(float, 0.0, 100.0, 0.05) var sprint_speed = 10
export(float, 0.0, 100.0, 0.05) var acceleration = 5
export(float, 0.0, 100.0, 0.05) var deceleration = 10

export(bool) var jump_enabled = true
export(float, 0.0, 100.0, 0.05) var jump_height = 7
export(float, 0.0, 100.0, 0.05) var gravity = 25
export(float, 0.0, 1.0, 0.05) var air_control = 0.3

export(bool) var crouch_toggle_mode = false
export(float, 0.0, 10.0, 0.05) var crouching_speed = 6 #speed you crouch down
export(float, 0.0, 100.0, 0.05) var throw_power = 20

# Runtime 
var direction: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO
var move_speed: float = 0
var snap: Vector3 = Vector3.ZERO
var crouching: bool = false
var jumping: bool = false

# Nodes
onready var head = get_node('Head')
onready var camera_x_pivot = get_node('Head/CameraXPivot')
onready var top_head_ray_cast = get_node('Head/TopHeadRayCast') 
onready var crosshair_ray_cast = get_node('Head/CameraXPivot/Crosshair')
onready var body_collision = get_node('BodyCollision')
onready var prop_container = get_node('Head/CameraXPivot/Container')


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and !(Input.is_action_pressed(KEY_INSPECT) and prop_container.prop):
		process_camera_motion(event.relative)

func _process(delta):
	set_direction()
	set_jumping()
	set_crouching()
	set_move_speed()
	if !(Input.is_action_pressed(KEY_INSPECT) and prop_container.prop):
		move(delta)
		crouch(delta)
	rigid_body_collision()

# Sets the 'move_speed' based on the argument.
# If none, based on the player's status (walk, run, crouch, etc)
func set_move_speed(speed = null) -> void:
	if speed is float:
		move_speed = speed
	else:
		move_speed = walk_speed
		if crouching and is_on_floor():
			move_speed = crouch_speed
		elif Input.is_action_pressed(KEY_SPRINT):
			move_speed = sprint_speed

# set direction from input then normalize
# This sets direction for xz-plane. Jump mechanics for y-axis.
func set_direction(dir = null) -> void:
	if dir is Vector3:
		direction = dir.normalized() * Vector3(1, 0, 1)
	else:
		direction = Vector3.ZERO
		if Input.is_action_pressed(KEY_FORWARD):
			direction -= transform.basis.z
		if Input.is_action_pressed(KEY_BACKWARD):
			direction += transform.basis.z
		if Input.is_action_pressed(KEY_LEFT):
			direction -= transform.basis.x
		if Input.is_action_pressed(KEY_RIGHT):
			direction += transform.basis.x
		direction = direction.normalized() * Vector3(1, 0, 1)


# Crouch input has 2 modes. The toggle mode and non-toggle.
func set_crouching(crouch = null) -> void:
	if crouch == null:
		if crouch_toggle_mode == true:
			if Input.is_action_just_pressed(KEY_CROUCH):
				crouching = !crouching
		else:
			if Input.is_action_pressed(KEY_CROUCH):
				crouching = true
			else:
				crouching = false
	elif crouch is bool:
		crouching = crouch

# If none given, it detects the jumping input from the player input
func set_jumping(jump = null) -> void:
	if jump is bool:
		jumping = jump
	else:
		jumping = Input.is_action_just_pressed(KEY_JUMP) and jump_enabled


# Moves the player. Processing of velocity on zx and y are
# done seperately as they have different mechanics.
func move(delta):
	# Process the x component
	var xz_comp = velocity * Vector3(1, 0, 1)
	var target_move_velocity: Vector3 = direction * move_speed
	var acc: float

	if direction.dot(xz_comp) > 0:
		acc = acceleration
	else:
		acc = deceleration

	if not is_on_floor():
		acc *= air_control

	xz_comp = xz_comp.linear_interpolate(target_move_velocity, acc * delta)

	# Process the y component
	var y_comp: Vector3 = velocity * Vector3(0, 1, 0)

	if top_head_ray_cast.is_colliding():
		y_comp.y = 0

	if is_on_floor():
		snap = - get_floor_normal() - get_floor_velocity() * delta
		if y_comp.y < 0:
			y_comp.y = 0
		if jumping and not top_head_ray_cast.is_colliding():
			y_comp.y = jump_height
			snap = Vector3.ZERO
	else: 
		if snap != Vector3.ZERO and y_comp.y != 0:
			y_comp.y = 0
		y_comp.y -= gravity * delta
		snap = Vector3.ZERO		

	# Combine 
	velocity = xz_comp + y_comp
	# Move the player
	var _velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, FLOOR_MAX_ANGLE, false)


# Logic for resizing the player collision capsule to crouch under an obstacle.
# This also moves the camera to a lower position when crouching.
func crouch(delta) -> void:
	if crouching:
		body_collision.shape.height -= crouching_speed * delta
	else:
		if not top_head_ray_cast.is_colliding():
			body_collision.shape.height += crouching_speed * delta

	body_collision.shape.height = clamp(body_collision.shape.height, CROUCH_HEIGHT, STAND_HEIGHT)
	head.translation.y = body_collision.shape.height / 2 + CAMERA_HEIGHT_OFFSET

# As move_and_slide_with_snap infinite inertia was set to false,
# this is a work around so that player can still push objects when bumped into it.
# The resistance of the rigid body depends on the weight of the rigid body.
func rigid_body_collision():
	for i in get_slide_count():
		var col = get_slide_collision(i)
		var c = col.collider
		if c is RigidBody and c.mode == RigidBody.MODE_RIGID:
			var dv = velocity.length() -  col.collider_velocity.length()
			if dv < 0:
				dv = 0
			var impulse = -col.normal.normalized() * dv
			c.apply_central_impulse(impulse)

# Rotates the camera based on the input
func process_camera_motion(relative_vector: Vector2) -> void:
	# rotate the player body
	rotate_y(deg2rad(-relative_vector.x * mouse_x_sensitivity))
	# rotate the camera on x axis (look up or down)
	camera_x_pivot.rotate_x(deg2rad(-relative_vector.y * mouse_y_sensitivity))
	camera_x_pivot.rotation.x = clamp(camera_x_pivot.rotation.x, deg2rad(-max_mouse_x_degree), deg2rad(max_mouse_x_degree))
