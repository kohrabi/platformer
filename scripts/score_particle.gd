extends Label

const BLINK_PER_SEC = 0.06;
const BLINK_TIME = 1;
var blinkpsTimer : float = 0.0;
var blinkTimer : float = 0.0;

func _ready() -> void:
	var tween : Tween = create_tween();
	tween.tween_property(self, "global_position:y", global_position.y - 8, 0.5) \
		#.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT);
	tween.tween_interval(1.0);
	visible = true;
	await tween.finished;
	queue_free();

func _process(delta: float) -> void:
	blinkTimer += delta;
	if (blinkTimer > BLINK_TIME):
		visible = true;
		return;
	blinkpsTimer += delta;
	if blinkpsTimer > BLINK_PER_SEC:
		blinkpsTimer = 0.0;
		visible = !visible;
