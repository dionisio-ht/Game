extends Area2D

@export var damage := 1

func _on_body_entered(body):
	if body.has_method("tomarDano"):
		body.tomarDano(damage)
