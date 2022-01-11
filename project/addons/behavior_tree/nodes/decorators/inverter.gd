extends Decorator

class_name InverterDecorator, "../../icons/inverter.png"

func tick(action, board):
	for c in get_children():
		var response = c.tick(action, board)
		if response == SUCCESS:
			return FAILURE
		if response == FAILURE:
			return SUCCESS
		return RUNNING
