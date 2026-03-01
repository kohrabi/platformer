extends Area2D
class_name Firework

enum Type {
	Normal,
	Explode
}

@export var particlePrefab : PackedScene;
@export var type : Type = Type.Normal;
@export var time : float = 8.0

var attached : bool = false;

func _on_body_entered(body: Node2D) -> void:
	if body is Player && !attached:
		attach(body);
	pass # Replace with function body.

func attach(player : Player) -> void:
	attached = true;
	visible = false;
	player.enter_firework(self);

func detach(playerPos : Vector2) -> void:
	var obj : Node2D = particlePrefab.instantiate();
	get_tree().root.add_child(obj);
	obj.global_position = playerPos;
	await get_tree().create_timer(0.5).timeout;
	visible = true;
	attached = false;
	pass;
