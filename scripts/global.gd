extends Node

var currentCamera : Camera;
var currentPlayer : Player;
var currentViewport : GameViewport;

func stop_time(time : float) -> void:
	Engine.time_scale = 0.01;
	await get_tree().create_timer(time, true, false, true).timeout;
	Engine.time_scale = 1.0;

func die() -> void:
	Global.currentCamera.shake();
	currentPlayer.change_state(Player.PlayerState.Die);
	await get_tree().create_timer(0.2).timeout;
	Transition.reload_current_scene.call_deferred();
	pass;
