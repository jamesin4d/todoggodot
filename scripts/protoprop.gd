#class for props which can be picked up

extends RigidBody
class_name Protoprop

# This controls how much it will turn if it bumps into something.
const BUMP: float = 10.0

# REQUIRED: Setup the Player, World, Prop collision layer.
const CONTAINER_MASK_ATTACH_MODE: int = 6
const CONTAINER_MASK_DETACH_MODE: int = 7
const KEY_DETACH: String = 'interact' 
const DEFAULT_THROW_POWER: float = 5.0
const KEY_FIRE: String = 'LMB'
const KEY_INSPECT: String = 'inspect'

# Exported (Never update this on runtime)
export(float, 0.0, 90.0, 0.05) var snap_velocity = 20.0
export(float, 0.0, 90.0, 0.05) var let_go_distance = 0.8
export(float, 0.0, 1.0, 0.05) var mouse_x_sensitivity = 0.1
export(float, 0.0, 1.0, 0.05) var mouse_y_sensitivity = 0.1

# Runtime
var prop_container: Node

func _input(event):
	if event is InputEventMouseMotion and prop_container and Input.is_action_pressed(KEY_INSPECT):
		# rotate the player body
		rotate_y(deg2rad(-event.relative.x * mouse_x_sensitivity))
		# rotate the camera on x axis (look up or down)
		rotate_x(deg2rad(-event.relative.y * mouse_y_sensitivity))


func _process(_delta):
	if prop_container:
		move()
		detach_and_throw()


# attempts to move prop towards container but if colliding or too far will detach
func move():
	var direction: Vector3 = global_transform.origin.direction_to(prop_container.global_transform.origin).normalized()
	var distance: float = global_transform.origin.distance_to(prop_container.global_transform.origin)
	# Moves the prop towards the prop container node.
	#linear_velocity = direction * distance * snap_velocity;
	#colliding? too far? detach
	if get_colliding_bodies() and distance > let_go_distance:
		detach()
	linear_velocity = direction * distance * snap_velocity


# takes a node to attach to as an arg
func attach(actor: Node):
	collision_mask = CONTAINER_MASK_ATTACH_MODE
	prop_container = actor
	angular_damp = BUMP

# these should be called by the actor
func detach():
	collision_mask = CONTAINER_MASK_DETACH_MODE
	prop_container = null
	angular_damp = -1


# Throws the object to a certain direction the parent is facing
func detach_and_throw() -> void:
	if Input.is_action_just_pressed(KEY_FIRE):
		var throw_power = DEFAULT_THROW_POWER
		if 'throw_power' in prop_container:
			throw_power = prop_container.throw_power

		apply_central_impulse(-prop_container.global_transform.basis.z * throw_power)
		detach()
