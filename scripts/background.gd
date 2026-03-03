extends TileMapLayer

const smallFireworkPrefab : PackedScene = preload("res://prefabs/particles/small_firework.tscn")

@export var X_SPAWN_RANGE : float = 256;
@export var X_SPAWN_PAD : float = 8;
@export var Y_SPAWN_POS : float = 92;
@export var Y_POS_RAND : float = 7.0;
@export var SPAWN_TIME : float = 1.0;
@export var SPAWN_SPACE : float = 0.5;
@export var SPAWN_NUM : int = 3;

var spawnTimer : float = 0.0;
var spawnNumber : int = 0;
var spawnSpace : float = 0.0;

func _ready() -> void:
	spawnTimer = SPAWN_TIME;
	spawnNumber = SPAWN_NUM;
	spawnSpace = SPAWN_SPACE;

func _process(delta: float) -> void:
	spawnTimer -= delta;
	if spawnTimer > 0:
		return;
	spawnSpace -= delta;
	if spawnSpace <= 0.0:
		var obj : Node2D = smallFireworkPrefab.instantiate();
		obj.global_position.x = randf_range(X_SPAWN_PAD, X_SPAWN_RANGE - X_SPAWN_PAD);
		obj.global_position.y = Y_SPAWN_POS + randf_range(-Y_POS_RAND, Y_POS_RAND);
		add_child(obj);
		spawnSpace = SPAWN_SPACE;
		spawnNumber -= 1;
		print(spawnNumber);
	if spawnNumber <= 0:
		spawnTimer = SPAWN_TIME;
		spawnSpace = SPAWN_SPACE;
		spawnNumber = SPAWN_NUM;
