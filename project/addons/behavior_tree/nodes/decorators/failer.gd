extends Decorator

class_name AlwaysFailDecorator, "../../icons/fail.png"

func tick(action, board):
	for c in get_children():
		var response = c.tick(action, board)
		if response == RUNNING:
			return RUNNING
		return FAILURE
