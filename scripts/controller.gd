tool
extends KinematicBody

# https://godottutorials.pro/fps-player-camera-tutorial/

const CAMERA_MOVE_SPEED = 20;
const CAMERA_MIN_MAX_ANGLES = [0, 90];
const GRAVITY = .05;
const JUMP_SPEED = 1;

var camera_sensitivity = 20;
var camera_sensitivy_multiplier = 1;

var mouse_delta = null;

var camera_velocity = Vector3();

var camera_mouse_delta = Vector2();

onready var camera_node = get_node(NodePath("camera").get_as_property_path());
onready var player_node = get_node(NodePath("player_kinematic_body").get_as_property_path());

var downwards_velocity = 0;

func _physics_process(delta):
	
	if (!camera_node): return;
	
	camera_velocity.x = 0;
	camera_velocity.y = 0;
	
	var sprinting_boost = 1;
	
	var movement = Vector3();
	
	if (Input.is_key_pressed(KEY_W)): movement -= global_transform.basis.y;
	if (Input.is_key_pressed(KEY_S)): movement += global_transform.basis.y;
	if (Input.is_key_pressed(KEY_A)): movement -= global_transform.basis.x;
	if (Input.is_key_pressed(KEY_D)): movement += global_transform.basis.x;
	if (Input.is_key_pressed(KEY_CONTROL)): sprinting_boost *= 2;
	if (Input.is_key_pressed(KEY_PAGEUP)): Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	if (Input.is_key_pressed(KEY_PAGEDOWN)): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	if (Input.is_key_pressed(KEY_SPACE) && is_on_floor()): downwards_velocity += JUMP_SPEED * 1;
	
	movement.y = -GRAVITY + downwards_velocity;
	
	downwards_velocity -= GRAVITY;
	
	camera_velocity = move_and_slide(movement.normalized() * CAMERA_MOVE_SPEED * sprinting_boost, Vector3.UP);
	
	if (is_on_floor()): 
		downwards_velocity = 0;
		movement.y = 0;

func _input(event):
	
	if (event is InputEventMouseMotion):
		
		mouse_delta = event.relative;
		
func _process(delta):
	
	if (mouse_delta == null): return;
	
	camera_node.rotation_degrees.x -= mouse_delta.y * camera_sensitivity * delta * camera_sensitivy_multiplier;
	camera_node.rotation_degrees.x = clamp(camera_node.rotation_degrees.x, CAMERA_MIN_MAX_ANGLES[0], CAMERA_MIN_MAX_ANGLES[1]);
	
	camera_node.rotation_degrees.y -= (mouse_delta.x * camera_sensitivity * delta * camera_sensitivy_multiplier);
	
	mouse_delta = Vector2();

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	OS.set_window_maximized(true);
	OS.set_window_title("beta 0.0.2");
