extends Area2D

@export var nextScene : PackedScene;

func _on_body_entered(body: Node2D) -> void:
	if nextScene == null:
		printerr("Next scene is null");
		return;
	Transition.change_scene_to_packed.call_deferred(nextScene);
	pass # Replace with function body.
