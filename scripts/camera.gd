extends Camera2D
class_name Camera

@export var cameraRegion : CollisionShape2D;
@export var followPlayer : bool = false;

var shakeMaxMagnitude : float = 0.0;
var shakeMagnitude : float = 0.0;
var shakeMaxTime : float = 0.0;
var shakeTime : float = 0.0;
var playerNode : Node2D;

func _ready() -> void:
	Global.currentCamera = self;
	if cameraRegion:
		assert(cameraRegion.shape is RectangleShape2D, "CameraRegion should be Rectangle");

func _process(delta: float) -> void:
	var shakePosition : Vector2 = Vector2.ZERO;
	if shakeTime > 0.0:
		shakeTime -= delta;
		shakeMagnitude = lerpf(0.0, shakeMaxMagnitude, shakeTime / shakeMaxTime);
		shakePosition.x = randf_range(-shakeMagnitude, shakeMagnitude);
		shakePosition.y = randf_range(-shakeMagnitude, shakeMagnitude);
	if followPlayer:
		var viewportRect : Rect2 = get_viewport_rect();
		var regionRect : Rect2 = (cameraRegion.shape as RectangleShape2D).get_rect();
		regionRect.position += cameraRegion.global_position;
		position = Global.currentPlayer.position - viewportRect.size / 2.0;
		position.x = clampf(position.x, regionRect.position.x, regionRect.end.x - viewportRect.size.x);
		position.y = clampf(position.y, regionRect.position.y, regionRect.end.y - viewportRect.size.y);
		position += shakePosition;
	else:
		position = shakePosition;

func shake(magnitude : float = 4, time : float = 0.4) -> void:
	shakeMaxMagnitude = magnitude;
	shakeMagnitude = shakeMaxMagnitude;
	shakeMaxTime = time;
	shakeTime = shakeMaxTime;
	pass;
