extends Area2D
class_name Bike

var attached : bool = false;
@export var goRight : bool = true;

func _ready() -> void:
	$Sprite2D.flip_h = goRight;

func _on_body_entered(body: Node2D) -> void:
	if body is Player && !attached:
		attach(body);
	pass # Replace with function body.

func attach(player : Player) -> void:
	if (player.state != Player.PlayerState.Normal):
		return;
	attached = true;
	visible = false;
	player.enter_bike(self);

func detach() -> void:
	await get_tree().create_timer(2.0).timeout;
	visible = true;
	attached = false;
	pass;
