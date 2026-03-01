extends Area2D


func _on_body_entered(body: Node2D) -> void:
	Transition.reload_current_scene.call_deferred();
	pass # Replace with function body.
