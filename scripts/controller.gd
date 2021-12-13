tool
extends KinematicBody

# https://godottutorials.pro/fps-player-camera-tutorial/

const CAMERA_MOVE_SPEED = 20;
const CAMERA_MIN_MAX_ANGLES = [-90, 90];
const GRAVITY = 0; #200;

var camera_sensitivity = 20;

var mouse_delta = null;

var camera_velocity = Vector3();

var camera_mouse_delta = Vector2();

onready var camera_node = get_node(NodePath("camera").get_as_property_path());
onready var player_node = get_node(NodePath("player_kinematic_body").get_as_property_path());

func _physics_process(delta):
	
	if (!camera_node): return;
	
	camera_velocity.x = 0;
	camera_velocity.y = 0;
	
	var movement = Vector3();
	
	if (Input.is_key_pressed(KEY_W)): movement -= global_transform.basis.y;
	if (Input.is_key_pressed(KEY_S)): movement += global_transform.basis.y;
	if (Input.is_key_pressed(KEY_A)): movement -= global_transform.basis.x;
	if (Input.is_key_pressed(KEY_D)): movement += global_transform.basis.x;
	if (Input.is_key_pressed(KEY_PAGEUP)): Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	if (Input.is_key_pressed(KEY_PAGEDOWN)): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	
	movement.y = 0;
	
	camera_velocity = move_and_slide(movement.normalized() * CAMERA_MOVE_SPEED, Vector3.UP);

func _input(event):
	
	if (event is InputEventMouseMotion):
		
		mouse_delta = event.relative;
		
func _process(delta):
	
	if (mouse_delta == null): return;
	
	camera_node.rotation_degrees.x -= mouse_delta.y * camera_sensitivity * delta;
	camera_node.rotation_degrees.x = clamp(camera_node.rotation_degrees.x, CAMERA_MIN_MAX_ANGLES[0], CAMERA_MIN_MAX_ANGLES[1]);
	
	player_node.rotation_degrees.y -= mouse_delta.x * camera_sensitivity * delta;
	
	mouse_delta = Vector2();

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	OS.set_window_maximized(true);
