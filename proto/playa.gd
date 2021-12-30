extends KinematicBody
#CAMERAMERA -----------------------------------------------------
export(float) var mouse_sensitivity = 8.0
export(NodePath) var head_path = "Head"
export(NodePath) var cam_path = "Head/Camera"
export(NodePath) var interact_ray_path = "Head/Interact_ray"
export(float) var FOV = 80.0
export(NodePath) var look_path = "Head/look_pos"
export(NodePath) var pickup_path = "Head/pick_pos"
# ---------------------------------------------- seperating here to contain the exports 
var mouse_axis := Vector2()
var look_vector # this is calculated runtime 
onready var head: Spatial = get_node(head_path)
onready var cam: Camera = get_node(cam_path)
onready var interact_ray: RayCast = get_node(interact_ray_path)
onready var look_pos: Position3D = get_node(look_path)
onready var pick_pos: Position3D = get_node(pickup_path)
#MOVESES 
# aparently this := operator allows the interpreter to infer the type, static typing is lame anyways 
# MOVEMENT -------------------------------------------------------
var velocity := Vector3()
var direction := Vector3()
var move_axis := Vector2()
var snap := Vector3()
var sprint_enabled := true
var sprinting := false
var crouch_enabled := true
var crouching := false
const MAX_FLOOR_ANGLE: float = deg2rad(46.0)
export(float) var gravity = 30.0
export(int) var walk_speed = 10
export(int) var sprint_speed = 16
export(int) var acceleration = 8
export(int) var deceleration = 10
export(float,0.0,1.0,0.05) var air_control = 0.03
export(int) var jump_height = 10 
var _speed: int
var _is_sprint_input := false
var _is_jump_input := false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.fov = FOV 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	movement_input()

# called every physics tick prick
func _physics_process(delta):
	move(delta)

# called when there is input, pussy.
func _input(event):
	if event is InputEventMouseMotion:
		mouse_axis = event.relative
		camera_rotation()

# handles camera rotation 	
func camera_rotation():
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return 
	if mouse_axis.length() > 0:
		var hor: float = -mouse_axis.x * (mouse_sensitivity/100)
		var ver: float = -mouse_axis.y * (mouse_sensitivity/100)
		mouse_axis = Vector2()
		rotate_y(deg2rad(hor))
		head.rotate_x(deg2rad(ver))
		# clamp mouse rotation
		var temp: Vector3 = head.rotation_degrees
		temp.x = clamp(temp.x,-90,90)
		head.rotation_degrees = temp 
		
func direction_input():
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	if move_axis.x >= 0.5:
		direction -= aim.z
	if move_axis.x <= -0.5:
		direction += aim.z
	if move_axis.y <= -0.5:
		direction -= aim.x 
	if move_axis.y >= 0.5:
		direction += aim.x 
	direction.y = 0 
	direction = direction.normalized()
	
func movement_input():
	move_axis.x = Input.get_action_strength("movement_forward") - Input.get_action_strength("movement_backward")
	move_axis.y = Input.get_action_strength("movement_right") -  Input.get_action_strength("movement_left")
	if Input.is_action_just_pressed("movement_jump"):
		_is_jump_input = true
	if Input.is_action_just_pressed("movement_sprint"):
		_is_sprint_input = true
		
	

# this was originally func walk(), but it handles more than walking describes.
func move(delta):
	direction_input()
	if is_on_floor():
		snap = -get_floor_normal() - get_floor_velocity() * delta
		# workaround for sliding down after jumping on a slope, dope.
		if velocity.y < 0:
			velocity.y = 0
		jump()
	else:
		# avoids 'vertical bump' when going off platforms
		if snap != Vector3.ZERO && velocity.y != 0:
			velocity.y = 0
		snap = Vector3.ZERO
		velocity.y -= gravity * delta
	
	sprint(delta)
	accelerate(delta)
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP,true,4,MAX_FLOOR_ANGLE)
	_is_jump_input = false
	_is_sprint_input = false


# handles making you jump, chump.
func jump():
	if _is_jump_input:
		velocity.y = jump_height
		snap = Vector3.ZERO		
		
# returns bool of whether you can sprint or not		
func can_sprint():
	return (sprint_enabled and is_on_floor() and _is_sprint_input and move_axis.x >= 0.5)		

# handles sprinting, not pimping.
func sprint(delta):
	if can_sprint():
		_speed = sprint_speed
		cam.set_fov(lerp(cam.fov, FOV*1.05, delta*8))
		sprinting = true
	else:
		_speed = walk_speed 
		cam.set_fov(lerp(cam.fov, FOV, delta*8))
		sprinting = false
		
# handles acceleration without hesitation
func accelerate(delta):
	var _tv: Vector3 = velocity # temporary velocity variable
	var _ta: float	# temporary accel variable
	var _target: Vector3 = direction * _speed 
	_tv.y = 0	
	
	if direction.dot(_tv) > 0:
		_ta = acceleration
	else: 
		_ta = deceleration
	if not is_on_floor():
		_ta *= air_control
		
	#interpolate
	_tv = _tv.linear_interpolate(_target, _ta*delta)
	velocity.x = _tv.x
	velocity.z = _tv.z
	
	#if it's essentially zero, it's zero. 
	if direction.dot(velocity) == 0:
		var _vc := 0.01 # velocity clamp variable 
		if abs(velocity.x) < _vc:
			velocity.x = 0
		if abs(velocity.z) < _vc:
			velocity.z = 0
