extends TileMapLayer

var smallFireworkPrefab = preload("res://prefabs/particles/small_firework.tscn")

const X_SPAWN_RANGE = 256;
const X_SPAWN_PAD = 8;
const Y_SPAWN_POS = 92;
const Y_POS_RAND = 7.0;
const SPAWN_TIME = 1.0;
const SPAWN_SPACE = 0.5;
const SPAWN_NUM = 3;

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
