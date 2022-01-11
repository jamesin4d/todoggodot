class_name State, "../fsm/icons/state.png"
extends Node
var state_machine = null 

#virtual functions of various types.

#recieves events from _unhandled_input() callbakc
func handle_input(_event: InputEvent) -> void:
	pass
#corresponds: _process callback	
func update(_delta: float) -> void:
	pass
#corresponds: _physics_process callback
func physics_update(_delta:float) -> void:
	pass
#_msg is a dict of data the state can self.init with 
func enter(_msg := {}) -> void:
	pass
# use as a clean up function 
func exit() -> void:
	pass
