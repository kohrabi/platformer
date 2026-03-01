extends Camera2D
class_name Camera

var shakeMaxMagnitude : float = 0.0;
var shakeMagnitude : float = 0.0;
var shakeMaxTime : float = 0.0;
var shakeTime : float = 0.0;

func _ready() -> void:
	Global.currentCamera = self;

func _process(delta: float) -> void:
	var shakePosition : Vector2 = Vector2.ZERO;
	if shakeTime > 0.0:
		shakeTime -= delta;
		shakeMagnitude = lerpf(0.0, shakeMaxMagnitude, shakeTime / shakeMaxTime);
		shakePosition.x = randf_range(-shakeMagnitude, shakeMagnitude);
		shakePosition.y = randf_range(-shakeMagnitude, shakeMagnitude);
	position = shakePosition;

func shake(magnitude : float = 4, time : float = 0.4) -> void:
	shakeMaxMagnitude = magnitude;
	shakeMagnitude = shakeMaxMagnitude;
	shakeMaxTime = time;
	shakeTime = shakeMaxTime;
	pass;
