extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@export var followRegion : Area2D;
@export var startFlip : bool = false;
var trackingPlayer : Player;
var following : bool = false;
var prevPosition : Vector2 = Vector2.ZERO;
var velocity : Vector2 = Vector2.ZERO;
var tracked : bool = false;

func _ready() -> void:
	followRegion.body_entered.connect(_follow_region_entered);
	followRegion.body_exited.connect(_follow_region_exited);
	sprite.flip_h = startFlip;

func _physics_process(delta: float) -> void:
	if trackingPlayer:
		var dir : float = sign(trackingPlayer.global_position.x - global_position.x);
		if tracked:
			global_position.x = \
				lerpf(global_position.x, trackingPlayer.global_position.x, clampf(10 * delta, 0.0, 1.0));
		else:
			global_position.x = \
				lerpf(global_position.x, trackingPlayer.global_position.x, clampf(5 * delta, 0.0, 1.0));
			if abs(global_position.x - trackingPlayer.global_position.x) <= 2.0:
				tracked = true;
		print(tracked);
		following = abs(global_position.x - prevPosition.x) > 0;
		if dir > 0:
			sprite.flip_h = false;
		elif dir < 0:
			sprite.flip_h = true;
		prevPosition = global_position;
	else:
		following = false;
	pass;

func _follow_region_entered(body: Node2D) -> void:
	if body is Player:
		trackingPlayer = body as Player;
		tracked = false;
	pass;

func _follow_region_exited(body: Node2D) -> void:
	if body is Player:
		trackingPlayer = null;
	pass;

func _on_body_entered(_body: Node2D) -> void:
	Global.die();
	pass # Replace with function body.
