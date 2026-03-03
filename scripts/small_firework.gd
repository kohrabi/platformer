extends AnimatedSprite2D

var timer : float = 2.0;
var speed : float = 10.0;
var finished : bool = false;

func _ready() -> void:
	speed += randf_range(-2, 5);
	timer += randf_range(-0.5, 0.5);

func _process(delta: float) -> void:
	if finished: return;
	timer -= delta;
	position.y -= speed * delta;
	if timer <= 0:
		explode();

func explode() -> void:
	play(&"explode");
	$Smallfireworkexplode.play();
	finished = true;
	await animation_finished;
	queue_free();
