extends Area2D
class_name Firework

var attached : bool = false;

func _on_body_entered(body: Node2D) -> void:
	if body is Player && !attached:
		attach(body);
	pass # Replace with function body.

func attach(player : Player) -> void:
	attached = true;
	visible = false;
	player.enter_firework(self);

func detach() -> void:
	attached = false;
	visible = true;
	pass;
