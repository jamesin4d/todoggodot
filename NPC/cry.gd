extends ActionLeaf

export (int) var cry_time = 200
var tcs = 0
func tick(actor,_board):
	if not actor.cried:
		actor.crier.set_emitting(true)
		for i in cry_time:
			tcs += 1
			if tcs >= cry_time:
				actor.cried = true
				actor.crier.set_emitting(false)
				return SUCCESS
			else:
				actor.cried = false
				return RUNNING

