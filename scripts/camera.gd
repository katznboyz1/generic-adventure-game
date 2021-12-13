tool
extends Camera

const CAMERA_FOV = 90;
const CAMERA_NEAR = .02;
const CAMERA_FAR = 750;

onready var camera_node = get_node(NodePath("camera").get_as_property_path());

func _physics_process(delta):
	
	if (!camera_node): return;
	
	var fov_multiplier = 1;
	
	if (Input.is_key_pressed(KEY_C)): fov_multiplier *= .5;
	
	camera_node.set_perspective(CAMERA_FOV * fov_multiplier, CAMERA_NEAR, CAMERA_FAR);
