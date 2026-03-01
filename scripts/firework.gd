extends Area2D
class_name Firework

var attached : bool = false;

func _on_body_entered(body: Node2D) -> void:
	if body is Player && !attached:
		attached = true;
		self.reparent.call_deferred(body);
		body.currentFirework = self;
		body.change_state(Player.PlayerState.Firework);
	pass # Replace with function body.
