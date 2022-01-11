extends BehaviorTree

class_name BehaviorTreeRoot, "../icons/tree.png"

const Board = preload("../board.gd")

export (bool) var enabled = true

onready var board = Board.new()

func _ready():
	if self.get_child_count() != 1:
		print("Behavior Tree error: Root should have one child")
		disable()
		return

func _physics_process(delta):
	if not enabled:
		return
	board.set("delta", delta)
	self.get_child(0).tick(get_parent(), board)

func enable():
	self.enabled = true

func disable():
	self.enabled = false
