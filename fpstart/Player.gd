extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const GRAV = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 5
const DEACCEL = 16
const MAX_SLOPE = 40
var camera
var rotation_helper
var mouse_sensitivity = 0.05
const MAX_SPRINT = 30
const SPRINT_ACCEL = 18
var sprinting = false 
var flashlight 

var dir = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	flashlight = $Rotation_Helper/Flashlight
#so far enjoying gdscript, it codes like butter except i HATE_THIS_CASE_SHIT
func process_input(delta):
	#walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	input_movement_vector = input_movement_vector.normalized() #don't need abnormal data
	#basis vectors are normalixed alredy
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	#----------------------------------------------
	# jumping
	#--------------------------------------------
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
			
	#capturing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	if Input.is_action_pressed("movement_sprint"):
		sprinting = true 
	else:
		sprinting = false
	
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	
func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	vel.y += delta * GRAV
	var hvel = vel
	hvel.y = 0
	var target = dir
	target *= MAX_SPEED
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	hvel = hvel.linear_interpolate(target,accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0,1,0),0.05,4,deg2rad(MAX_SLOPE))
	if sprinting:
		target *= MAX_SPRINT
	else:
		target *= MAX_SPEED
	#the tutorial seperates this out into another if block but i think it could be combined with the above
	#i'll follow the tutorial and make changes later.
	if sprinting:
		accel = SPRINT_ACCEL
	else:
		accel = ACCEL

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y*mouse_sensitivity))
		self.rotate_y(deg2rad(event.relative.x*mouse_sensitivity*-1))
		
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x,-70,70)
		rotation_helper.rotation_degrees = camera_rot

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
