extends ActionLeaf

export (int) var walk_time = 170 
var time_walked = 0
func tick(actor, _board):
	if not actor.has_walked:
		for i in walk_time:
			time_walked += 1
			if time_walked >= walk_time:
				actor.adjust_dir(0,0)
				actor.has_walked = true
				return SUCCESS
			else:
				actor.adjust_dir(0,0.8)
				actor.has_walked = false
				return RUNNING
