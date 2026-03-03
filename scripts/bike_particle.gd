extends CharacterBody2D

const BIKE_EXPLOSION = preload("uid://bx213sne2oo3i")

@onready var particle: CPUParticles2D = $Sprite2D/BikeParticle
@onready var sprite: Sprite2D = $Sprite2D
const GRAVITY = 200;
const MAX_FALL_SPEED = 200;

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED);
	if velocity.x > 0:
		sprite.flip_h = true;
		particle.position.x = abs(particle.position.x) * -1;
		particle.direction.x = abs(particle.direction.x) * -1;
	elif velocity.x < 0:
		sprite.flip_h = false;
		particle.position.x = abs(particle.position.x) * 1;
		particle.direction.x = abs(particle.direction.x) * 1;
	move_and_slide();
	if is_on_wall() || global_position.y <= -2000.0:
		queue_free();
		var obj : Node2D = BIKE_EXPLOSION.instantiate();
		obj.global_position = global_position;
		GameViewport.get_current_scene().add_child(obj);
		var explode : = $Explode;
		explode.reparent(GameViewport.get_current_scene());
		explode.play();
		explode.finished.connect((func() -> void:
			explode.queue_free()
		));
		
