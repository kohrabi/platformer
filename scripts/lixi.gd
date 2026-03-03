extends Area2D

var scoreParticlePrefab : PackedScene = preload("res://prefabs/particles/score_particle.tscn");

@export var SPEED : float = 0.1;
@export var DISTANCE : float = 1.0;
@onready var sprite: Sprite2D = $Sprite2D
var time : float = 0.0;



func _process(delta: float) -> void:
	sprite.position.y = sin(time * SPEED) * DISTANCE; 
	time += delta;


func _on_body_entered(body: Node2D) -> void:
	var obj : Label = scoreParticlePrefab.instantiate();
	obj.global_position = global_position - Vector2(obj.size.x / 2.0, 0.0);
	GameViewport.get_current_scene().add_child(obj);
	Global.stop_time(0.1);
	queue_free();
	pass # Replace with function body.
