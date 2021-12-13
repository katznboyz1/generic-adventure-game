tool
extends KinematicBody

# https://godottutorials.pro/fps-player-camera-tutorial/

const CAMERA_MOVE_SPEED = 10;
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
	
	var camera_input = Vector2();
	
	var speed = 0;
	
	if (Input.is_key_pressed(KEY_W)): speed = CAMERA_MOVE_SPEED;
	if (Input.is_key_pressed(KEY_S)): speed = -CAMERA_MOVE_SPEED;
	if (Input.is_key_pressed(KEY_A)): camera_input.x -= 1;
	if (Input.is_key_pressed(KEY_D)): camera_input.x += 1;
	if (Input.is_key_pressed(KEY_M)): Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	if (Input.is_key_pressed(KEY_N)): Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	
	var camera_global_transform = -global_transform.basis.y;
	
	camera_global_transform.y = 0;
	
	camera_velocity = move_and_slide(camera_global_transform.normalized() * speed, Vector3.UP);

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
