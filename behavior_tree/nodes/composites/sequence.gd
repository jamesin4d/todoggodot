extends Composite

class_name SequenceComposite, "../../icons/sequencer.png"

func tick(actor, board):
	for c in get_children():
		var response = c.tick(actor, board)
		if response != SUCCESS:
			return response
	return SUCCESS
