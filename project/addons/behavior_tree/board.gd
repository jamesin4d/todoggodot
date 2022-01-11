extends Reference

var board = {}

func set(key, value, board_name = 'default'):
	if not board.has(board_name):
		board[board_name] = {}

	board[board_name][key] = value


func get(key, default_value = null, board_name = 'default'):
	if has(key, board_name):
		return board[board_name].get(key, default_value)
	return default_value


func has(key, board_name = 'default'):
	return board.has(board_name) and board[board_name].has(key) and board[board_name][key] != null


func erase(key, board_name = 'default'):
	if board.has(board_name):
		 board[board_name][key] = null
