extends Area2D

@export var SPEED : float = 0.1;
@export var DISTANCE : float = 1.0;
@onready var sprite: Sprite2D = $Sprite2D
var time : float = 0.0;


func _process(delta: float) -> void:
	sprite.position.y = sin(time * SPEED) * DISTANCE; 
	time += delta;


func _on_body_entered(body: Node2D) -> void:
	queue_free();
	pass # Replace with function body.
