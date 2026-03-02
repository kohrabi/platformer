extends CharacterBody2D
class_name Player

enum PlayerState {
	Normal,
	Firework,
	FireworkExplode,
	Die,
	Bike,
	Accel
}

enum FireworkType {
	Normal,
	Explode
}

@export_group("Normal")
@export var SPEED : float = 160.0
@export var ACCELERATION : float = 160 * 5000
@export var DECELERATION : float = 160 * 10
@export var JUMP_VELOCITY : float = -400.0
@export var JUMP_RELEASE_FORCE : float = 0.5
@export var GRAVITY : float = 1300.0
@export var MAX_FALL_SPEED : float = 400.0
@export_group("Powerup")
@export_subgroup("Firework")
@export var FIREWORK_SPEED : float = 100.0;
@export var FIREWORK_MAX_SPEED : float = 80;
@export var FIREWORK_IGNORE_INPUT_TIME : float = 0.06;
@export_subgroup("Firework Explode")
@export var FIREWORK_EXPLODE_SPEED : float = 100.0; # Initial Speed
@export var FIREWORK_EXPLODE_TIME : float = 0.2;
@export var FIREWORK_EXPLODE_DECELERATION : float = 100;
@export var FIREWORK_EXPLODE_GRAVITY : float = 100;
@export_subgroup("Bike")
@export var BIKE_SPEED : float = 100.0;
@export var BIKE_ACCELERATION : float = 100.0;
@export var BIKE_LEAVE_SPEED : float = 50.0;
@export var BIKE_LEAVE_GRAVITY : float = 50.0;
@export var BIKE_LEAVE_TIME : float = 0.3;
@export var BIKE_LEAVE_DECELERATION : float = 50.0; # Initial Speed


var coyote_time : float = 0.1
var coyote_timer : float = 0.0
var jump_buffer : float = 0.1
var jump_buffer_timer : float = 0.0
var onFloor : bool = false;
var prevOnFloor : bool = false;
var aimDir : Vector2 = Vector2.ZERO;
var inputAxis : float = 0.0;
var currentFirework : Firework;

var accelTime : float = 0.0;
var useInput : bool = false;
var accelSpeed : float = 0.0;
var accelTo : float = 0.0;
var decelSpeed : float = 0.0;
var accelGravity : float = 0.0;

var fireworkTimer : float = 0.0;
var fireworkIgnoreInputTimer : float = 0.0;
var fireworkDefaultDir : Vector2 = Vector2.ZERO;
var fireworkType : FireworkType = FireworkType.Normal;

var currentBike : Bike;

var state : PlayerState = PlayerState.Normal;
@onready var fireworkParticle: CPUParticles2D = $SpriteScaler/Sprite2D/FireworkParticle
@onready var bikeParticle: CPUParticles2D = $SpriteScaler/Sprite2D/BikeParticle
@onready var sprite : Sprite2D = $SpriteScaler/Sprite2D;
@onready var spriteScaler : Node2D = $SpriteScaler;

func _ready() -> void:
	Global.currentPlayer = self;
	prevOnFloor = is_on_floor();

func _process(_delta: float) -> void:
	inputAxis = Input.get_axis("move_left", "move_right");
	var dir : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	if (dir != Vector2.ZERO):
		aimDir = dir;
		
	if Input.is_action_just_pressed("reset"):
		Transition.reload_current_scene.call_deferred();
	
	match state:
		PlayerState.Normal:
			if Input.is_action_just_pressed("jump"):
				jump_buffer_timer = jump_buffer
			pass;
		PlayerState.Firework:
			if Input.is_action_just_pressed("jump"):
				velocity.y += JUMP_VELOCITY
				exit_firework();
		PlayerState.Bike:
			if Input.is_action_just_pressed("jump"):
				change_state(PlayerState.Accel);

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
			spriteScaler.global_rotation = velocity.angle() + PI / 2;
			
			var collision : KinematicCollision2D = move_and_collide(velocity * delta);
			if collision:
				exit_firework();
				velocity = velocity.bounce(collision.get_normal());
			#move_and_slide();
			
			if fireworkTimer <= 0:
				exit_firework();
			fireworkTimer -= delta;
		PlayerState.Bike:
			var dir : float = 1 if currentBike.goRight else -1 
			onFloor = is_on_floor();
			if not onFloor:
				velocity.y = min(velocity.y + FIREWORK_EXPLODE_GRAVITY * delta, MAX_FALL_SPEED)
			var collision : KinematicCollision2D = move_and_collide(velocity * delta, true);
			if collision:
				var dirVec : Vector2 = Vector2(dir, 0);
				dirVec = dirVec.slide(collision.get_normal()) * 1.4;
				velocity = velocity.move_toward(BIKE_SPEED * dirVec, BIKE_ACCELERATION * delta);
				rotation = dirVec.angle();
			else:
				velocity.x = \
					move_toward(velocity.x, BIKE_SPEED * dir, BIKE_ACCELERATION * delta);
			move_and_slide();
			if is_on_wall():
				change_state(PlayerState.Accel);

		PlayerState.Accel:
			onFloor = is_on_floor();
			if not onFloor:
				velocity.y = min(velocity.y + accelGravity * delta, MAX_FALL_SPEED)
			if useInput:
				velocity.x = \
					move_toward(velocity.x, accelTo * inputAxis, accelSpeed * delta);
			else:
				velocity.x = \
					move_toward(velocity.x, accelTo, accelSpeed * delta);
			move_and_slide();
			accelTime -= delta;
			if accelTime <= 0.0:
				change_state(PlayerState.Normal);
			print(velocity);
	animation_code(inputAxis);

func change_state(nextState : PlayerState) -> void:
	if state == nextState:
		printerr("Currently in nextState ", PlayerState.find_key(nextState));
		return;
	var prevState : PlayerState = state;
	match state:
		PlayerState.Normal:
			velocity = Vector2.ZERO;
		PlayerState.Firework:
			if currentFirework:
				currentFirework.detach(global_position);
				# Should be going to accel
				if currentFirework.type == Firework.Type.Explode:
					velocity = (aimDir - Vector2(0, 0.5)).normalized() * FIREWORK_EXPLODE_SPEED;
					useInput = true;
					accelTime = FIREWORK_EXPLODE_TIME;
					accelGravity = FIREWORK_EXPLODE_GRAVITY;
					accelTo = SPEED;
					accelSpeed = FIREWORK_EXPLODE_DECELERATION;
			Global.currentCamera.shake(2, 0.2);
			Global.stop_time(0.1);
			spriteScaler.global_rotation = 0;
			fireworkParticle.emitting = false;
			currentFirework = null;
		PlayerState.Bike:
			currentBike.detach();
			velocity = Vector2(SPEED, JUMP_VELOCITY);
			move_and_collide(Vector2.UP * 8.0);
			bikeParticle.emitting = false;
			currentBike = null;
			rotation = 0.0;
			
			# Should be going to accel
			velocity = Vector2(aimDir.x, -1.0).normalized() * BIKE_LEAVE_SPEED;
			useInput = true;
			accelTime = BIKE_LEAVE_TIME;
			accelGravity = BIKE_LEAVE_GRAVITY;
			accelTo = SPEED;
			accelSpeed = BIKE_LEAVE_DECELERATION;
	state = nextState;
	match state:
		PlayerState.Firework:
			match currentFirework.type:
				Firework.Type.Normal:
					fireworkType = FireworkType.Normal;
				Firework.Type.Explode:
					fireworkType = FireworkType.Explode;
			fireworkTimer = currentFirework.time;
			fireworkDefaultDir = Vector2.UP
			aimDir = fireworkDefaultDir;
			fireworkIgnoreInputTimer = FIREWORK_IGNORE_INPUT_TIME;
			fireworkParticle.emitting = true;
			Global.stop_time(0.1);
		PlayerState.Bike:
			Global.stop_time(0.1);
			if !is_on_floor():
				move_and_collide(Vector2.DOWN * 8.0);
			bikeParticle.emitting = true;

func handle_jump(delta : float) -> void:
	if onFloor:
		coyote_timer = coyote_time
	
	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			velocity.y += JUMP_VELOCITY
			jump_buffer_timer = 0
			coyote_timer = 0
		jump_buffer_timer -= delta
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_RELEASE_FORCE

func animation_code(inputAxis : float) -> void:
	if (inputAxis > 0):
		sprite.flip_h = false;
	elif (inputAxis < 0):
		sprite.flip_h = true;

func exit_firework() -> void:
	match currentFirework.type:
		Firework.Type.Normal:
			change_state(Player.PlayerState.Normal);
		Firework.Type.Explode:
			change_state(Player.PlayerState.Accel);

func enter_firework(firework : Firework) -> void:
	currentFirework = firework;
	change_state(Player.PlayerState.Firework);

func enter_bike(bike : Bike) -> void:
	currentBike = bike;
	change_state(Player.PlayerState.Bike);
	pass;
