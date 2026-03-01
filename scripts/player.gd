extends CharacterBody2D
class_name Player

var fireworkParticlePrefab : PackedScene = preload("res://prefabs/particles/firework.tscn");

enum PlayerState {
	Normal,
	Firework
}

@export_group("Normal")
@export var SPEED : float = 160.0
@export var ACCELERATION : float = 160 * 5000
@export var DECELERATION : float = 160 * 10
@export var JUMP_VELOCITY : float = -400.0
@export var MAX_JUMP_HEIGHT : float = -400 * 1.4;
@export var JUMP_RELEASE_FORCE : float = 0.5
@export var GRAVITY : float = 1300.0
@export var MAX_FALL_SPEED : float = 400.0
@export_group("Speed")
@export var FIREWORK_SPEED : float = 100.0;
@export var FIREWORK_TIME : float = 1.0;
@export var FIREWORK_MAX_SPEED : float = 80;
@export var FIREWORK_IGNORE_INPUT_TIME : float = 0.06;


var coyote_time : float = 0.1
var coyote_timer : float = 0.0
var jump_buffer : float = 0.1
var jump_buffer_timer : float = 0.0
var onFloor : bool = false;
var prevOnFloor : bool = false;
var aimDir : Vector2 = Vector2.ZERO;
var inputAxis : float = 0.0;
var currentFirework : Firework;

var fireworkTimer : float = 0.0;
var fireworkIgnoreInputTimer : float = 0.0;
var fireworkDefaultDir : Vector2 = Vector2.ZERO;

var state : PlayerState = PlayerState.Normal;
@onready var fireworkParticle: CPUParticles2D = $SpriteScaler/Sprite2D/FireworkParticle
@onready var sprite : Sprite2D = $SpriteScaler/Sprite2D;
@onready var spriteScaler : Node2D = $SpriteScaler;

func _ready() -> void:
	prevOnFloor = is_on_floor();

func _process(delta: float) -> void:
	inputAxis = Input.get_axis("move_left", "move_right");
	var dir : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	if (dir != Vector2.ZERO):
		aimDir = dir;
		
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene();
	
	match state:
		PlayerState.Normal:
			if Input.is_action_just_pressed("jump"):
				jump_buffer_timer = jump_buffer
			pass;
		PlayerState.Firework:
			if Input.is_action_just_pressed("jump"):
				velocity.y += JUMP_VELOCITY
				change_state(PlayerState.Normal);

func _physics_process(delta: float) -> void:
	match state:
		PlayerState.Normal:
			onFloor = is_on_floor();
			if not onFloor:
				velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
			
			if inputAxis != 0:
				velocity.x = move_toward(velocity.x, SPEED * inputAxis, ACCELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
			
			handle_jump(delta)
			
			move_and_slide();
			animation_code(inputAxis);
			if onFloor:
				coyote_timer = coyote_time
			elif coyote_timer > 0:
				coyote_timer -= delta
			prevOnFloor = onFloor;
		PlayerState.Firework:
			if fireworkIgnoreInputTimer > 0:
				fireworkIgnoreInputTimer -= delta;
				velocity += fireworkDefaultDir.normalized() * FIREWORK_SPEED * delta;
			else:
				var desiredDir : Vector2 = aimDir.normalized();
				desiredDir = (desiredDir + velocity.normalized()) / 2.0;
				desiredDir = desiredDir.normalized();
				velocity += desiredDir * FIREWORK_SPEED * delta;
			velocity = velocity.limit_length(FIREWORK_MAX_SPEED);
			#if currentFirework:
			spriteScaler.global_rotation = velocity.angle() + PI / 2;
			
			var collision : KinematicCollision2D = move_and_collide(velocity * delta);
			if collision:
				change_state(PlayerState.Normal);
				velocity = velocity.bounce(collision.get_normal());
			#move_and_slide();
			
			if fireworkTimer <= 0:
				change_state(PlayerState.Normal);
			fireworkTimer -= delta;

func change_state(nextState : PlayerState) -> void:
	if state == nextState:
		printerr("Currently in nextState ", PlayerState.find_key(nextState));
		return;
	match state:
		PlayerState.Normal:
			velocity = Vector2.ZERO;
			pass;
		PlayerState.Firework:
			if currentFirework:
				currentFirework.queue_free();
			spriteScaler.global_rotation = 0
			fireworkParticle.emitting = false;
			var obj : Node2D = fireworkParticlePrefab.instantiate();
			get_tree().root.add_child(obj);
			obj.global_position = global_position;
			#velocity = Vector2.ZERO;
	state = nextState;
	match state:
		PlayerState.Firework:
			fireworkTimer = FIREWORK_TIME;
			fireworkDefaultDir = Vector2.UP
			aimDir = fireworkDefaultDir;
			currentFirework.global_position = global_position;
			currentFirework.visible = false;
			fireworkIgnoreInputTimer = FIREWORK_IGNORE_INPUT_TIME;
			fireworkParticle.emitting = true;
			#velocity = aimDir * FIREWORK_MAX_SPEED;
			pass;

func handle_jump(delta : float) -> void:
	if onFloor:
		coyote_timer = coyote_time
	
	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			velocity.y += JUMP_VELOCITY
			jump_buffer_timer = 0
			coyote_timer = 0
			#jump_begin_tween();
		jump_buffer_timer -= delta
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_RELEASE_FORCE
		
	#velocity.y = max(velocity.y, MAX_JUMP_HEIGHT);

func animation_code(inputAxis : float) -> void:
	if (inputAxis > 0):
		sprite.flip_h = false;
		#sprite.scale.x = abs(sprite.scale.x) * 1;
	elif (inputAxis < 0):
		sprite.flip_h = true;
		#sprite.scale.x = abs(sprite.scale.x) * -1;
	
	#if (onFloor == true && prevOnFloor == false):
		#jump_end_tween();
		#pass;
#
	#spriteScaler.scale.x = lerpf(spriteScaler.scale.x, 1, 0.3);
	#spriteScaler.scale.y = lerpf(spriteScaler.scale.y, 1, 0.3);
	#
	#if (velocity.y > 0 && !onFloor):
		#var lerpValue : float = clampf(velocity.y / (MAX_FALL_SPEED * 4), 0, 1);
		#spriteScaler.scale.x = lerpf(spriteScaler.scale.x, 0.5, lerpValue);
		#spriteScaler.scale.y = lerpf(spriteScaler.scale.y, 2, lerpValue);
	#if (onFloor):
		#spriteScaler.scale.x = lerpf(spriteScaler.scale.x, 1, 0.3);
		#spriteScaler.scale.y = lerpf(spriteScaler.scale.y, 1, 0.3);

func jump_begin_tween() -> void:
	var tween : Tween = get_tree().create_tween();
	tween.bind_node(self);
	tween.set_parallel(true);
	tween.tween_property(spriteScaler, "scale:x", 1.8, 0.15) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT);
	tween.tween_property(spriteScaler, "scale:y", 0.5, 0.1) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT);
	tween.chain().tween_property(spriteScaler, "scale:x", 1, 0.15) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT);
	tween.tween_property(spriteScaler, "scale:y", 1, 0.25) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT);
	
func jump_end_tween() -> void:
	var tween : Tween = get_tree().create_tween();
	tween.bind_node(self);
	tween.set_parallel(true);
	tween.tween_property(spriteScaler, "scale:x", 1.5, 0.1) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT);
	tween.tween_property(spriteScaler, "scale:y", 0.6, 0.05) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT);
	tween.chain().tween_property(spriteScaler, "scale:x", 1, 0.1) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT);
	tween.tween_property(spriteScaler, "scale:y", 1, 0.15) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT);
