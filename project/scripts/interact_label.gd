extends Label
export(NodePath) var crp = "Head/CameraXPivot/Crosshair"
onready var crosshair_ray: RayCast = get_node(crp)
func _ready():
	pass

func _process(_delta):
	var x = crosshair_ray.get_collider()
	if x is Protoprop and !x.prop_container:
		set_text("[ E ] Pick up: " + x.get_name())
	else:
		set_text("")
