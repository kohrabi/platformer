extends CanvasLayer

@onready var animator: AnimationTree = $ColorRect/AnimationTree
var transitioning : bool = false;

func _ready() -> void:
	get_tree().scene_changed.connect(transition_out);

func change_scene_to_packed(scene : PackedScene) -> void:
	if transitioning:
		return;
	transition_in();
	transitioning = true;
	await get_tree().create_timer(0.5).timeout;
	GameViewport.change_scene_to_packed(scene);
	transitioning = false;
	transition_out();

func reload_current_scene() -> void:
	if transitioning:
		return;
	transition_in();
	transitioning = true;
	await get_tree().create_timer(0.5).timeout;
	GameViewport.remove_children();
	GameViewport.reload_current_scene();
	await get_tree().create_timer(0.1).timeout;
	transition_out();
	transitioning = false;
	

func transition_in() -> void:
	animator.set("parameters/conditions/transitionIn", true);
	
func transition_out() -> void:
	animator.set("parameters/conditions/transitionOut", true);
