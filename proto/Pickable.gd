extends RigidBody
var picked_up 
var holder

func pick_up(player):
	holder = player
	if picked_up:
		leave()
	else:
		carry()
		
func _process(delta):
	if picked_up:
		set_global_transform(holder.get_node("Rotation_Helper/Camera/pickup_pos").get_global_transform())#here i'm going to need to find a point on the player 
		# to position the item i've picked up, the place i'm pulling from gives the player a "Yaw/camera/pickup_pos" reference.
		# i'll figure it out.
		
func carry():
	$CollisionShape.set_disabled(true)
	holder.carried_object = self
	self.set_mode(1)
	picked_up = true
	
func leave():
	$CollisionShape.set_disabled(false)
	holder.carried_object = null
	self.set_mode(0)
	picked_up = false
	
func throw(p):
	leave()
	apply_impulse(Vector3(),holder.look_vector * Vector3(p,p,p))


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

