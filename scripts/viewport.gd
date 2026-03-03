extends CanvasLayer

const DISABLE = false;
@onready var sub_viewport: SubViewport = $SubViewport
var currentScenePath: String

func _ready() -> void:
	if DISABLE: return;
	get_tree().scene_changed.connect(_on_scene_changed);
	_on_scene_changed();

func _on_scene_changed() -> void:
	currentScenePath = get_tree().current_scene.scene_file_path
	get_tree().current_scene.reparent.call_deferred(sub_viewport);
	pass;

func get_current_scene() -> Node:
	return sub_viewport.get_child(0);

func remove_children() -> void:
	for child in sub_viewport.get_children():
		child.queue_free();

func change_scene_to_packed(scene: PackedScene) -> void:
	remove_children();
	get_tree().change_scene_to_packed(scene);

func change_scene_to_file(file: String) -> void:
	remove_children();
	get_tree().change_scene_to_file(file);

func reload_current_scene() -> void:
	if currentScenePath:
		change_scene_to_file(currentScenePath)


func _on_texture_button_pressed() -> void:
	pass # Replace with function body.
