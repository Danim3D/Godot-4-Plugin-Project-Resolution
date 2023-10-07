extends Node2D

func _input(event):
	if event is InputEventKey:
		get_tree().quit()
