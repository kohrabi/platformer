extends Control


func _ready() -> void:
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		visible = true;
		process_mode = Node.PROCESS_MODE_ALWAYS;
	else:
		visible = false;
		process_mode = Node.PROCESS_MODE_DISABLED;
		
