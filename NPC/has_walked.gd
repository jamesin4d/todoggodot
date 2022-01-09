extends ConditionLeaf


func tick(actor,_board):
	if actor.has_walked:
		actor.cried = false
		return SUCCESS
	else:
		actor.cried = true
		return FAILURE
