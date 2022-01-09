extends Node
class_name StateMachine, "../fsm/icons/state_machine.png"

#for the record all of this static typed shiz apparently speeds things up
# as static typed is just a hair faster than dynamic right now in godot.
signal transitioned(state_name)
export var start_state := NodePath()
onready var state: State = get_node(start_state)

func _ready() -> void:
	yield(owner, "ready")
	for c in get_children():
		c.state_machine = self
	state.enter()
	
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)
	
func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func transition(target_state: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state):
		return
	state.exit()
	state = get_node(target_state)
	state.enter(msg)
	emit_signal("transitioned",state.name)
