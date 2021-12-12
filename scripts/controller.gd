tool
extends KinematicBody

# https://godottutorials.pro/fps-player-camera-tutorial/

const CAMERA_MOVE_SPEED = 4;
const CAMERA_MIN_MAX_ANGLES = [-89, 89];
const GRAVITY = 0; #200;

var camera_sensitivity = 20;

var mouse_delta = null;

var camera_velocity = Vector3();

var camera_mouse_delta = Vector2();

onready var camera_node = get_node(NodePath("camera").get_as_property_path());

func _physics_process(delta):
	
	camera_velocity.x = 0;
	camera_velocity.y = 0;
	
	var camera_input = Vector2();
	
	if (Input.is_key_pressed(KEY_W)): camera_input.y -= 1;
	if (Input.is_key_pressed(KEY_S)): camera_input.y += 1;
	if (Input.is_key_pressed(KEY_A)): camera_input.x -= 1;
	if (Input.is_key_pressed(KEY_D)): camera_input.x += 1;
	
	camera_input = camera_input.normalized();
	
	var forward_direction = global_transform.basis.z;
	var right_direction = global_transform.basis.x;
	
	var relative_direction = (forward_direction * camera_input.y + right_direction * camera_input.x);
	
	camera_velocity.x = relative_direction.x * CAMERA_MOVE_SPEED;
	camera_velocity.z = -relative_direction.y * CAMERA_MOVE_SPEED;
	#camera_velocity.y -= delta * GRAVITY;
	
	camera_velocity = move_and_slide(camera_velocity, Vector3.UP);

func _input(event):
	
	if (event is InputEventMouseMotion):
		
		mouse_delta = event.relative;
		
func _process(delta):
	
	if (mouse_delta == null): return;
	
	camera_node.rotation_degrees.x -= mouse_delta.y * camera_sensitivity * delta;
	camera_node.rotation_degrees.x = clamp(camera_node.rotation_degrees.x, CAMERA_MIN_MAX_ANGLES[0], CAMERA_MIN_MAX_ANGLES[1]);
	
	rotation_degrees.y -= mouse_delta.x * camera_sensitivity * delta;
	
	mouse_delta = Vector2();

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	OS.set_window_fullscreen(true);
