tool
extends Spatial

const MAX_INT = 0x7FFFFFFFFFFFFFFF;
var NOISE_SEED = 1; #rand_range(0, MAX_INT);
const NOISE_OCTAVES = 2;
const NOISE_PERIOD = 150 / 5;
const NOISE_LACUNARITY = 2;
const NOISE_PERSISTENCE = .5;
const HEIGHT_MULTIPLIER = 20;
const UV_OFFSET = .1 * 10;

const INITIAL_MAP_U_DISTANCE_FROM_ORIGIN = 250;
const INITIAL_MAP_V_DISTANCE_FROM_ORIGIN = 250;
const INITIAL_MAP_MIN_MAX_HEIGHTS = [-10, 50];

var terrain_generation_initialized = 0;
var noise_generator : OpenSimplexNoise = null;

var vertices = PoolVector3Array();
var uvs = PoolVector2Array();
var indices = PoolIntArray();
var normals = PoolVector3Array();

var mesh_instance : MeshInstance = null;

func initialize_terrain_generator():
	
	terrain_generation_initialized = true;
	
	noise_generator = OpenSimplexNoise.new();
	noise_generator.seed = NOISE_SEED;
	noise_generator.octaves = NOISE_OCTAVES;
	noise_generator.period = NOISE_PERIOD;
	noise_generator.lacunarity = NOISE_LACUNARITY;
	noise_generator.persistence = NOISE_PERSISTENCE;

func generate_terrain():
	
	# mesh/uv
	var index_mesh = 0;
	
	for u_coord in range(-INITIAL_MAP_U_DISTANCE_FROM_ORIGIN, INITIAL_MAP_U_DISTANCE_FROM_ORIGIN):
		
		for v_coord in range(-INITIAL_MAP_V_DISTANCE_FROM_ORIGIN, INITIAL_MAP_V_DISTANCE_FROM_ORIGIN):
			
			var height = noise_generator.get_noise_2d(u_coord, v_coord) * HEIGHT_MULTIPLIER;
			
			if (height < INITIAL_MAP_MIN_MAX_HEIGHTS[0]): height = INITIAL_MAP_MIN_MAX_HEIGHTS[0];
			if (height > INITIAL_MAP_MIN_MAX_HEIGHTS[1]): height = INITIAL_MAP_MIN_MAX_HEIGHTS[1];
			
			vertices.push_back(Vector3(u_coord, height, v_coord));
			
			uvs.push_back(Vector2(u_coord * UV_OFFSET, v_coord * UV_OFFSET));
			
			index_mesh += 1;
	
	var incides_size = (((INITIAL_MAP_U_DISTANCE_FROM_ORIGIN + 0) * 2) + 0) * ((INITIAL_MAP_U_DISTANCE_FROM_ORIGIN - 0) * 2);
	
	# incices
	var indices_index = 0;
	
	for u_coord in range(-INITIAL_MAP_U_DISTANCE_FROM_ORIGIN, INITIAL_MAP_U_DISTANCE_FROM_ORIGIN):
		
		for v_coord in range(-INITIAL_MAP_V_DISTANCE_FROM_ORIGIN, INITIAL_MAP_V_DISTANCE_FROM_ORIGIN):
			
			var index_1 = indices_index;
			var index_2 = indices_index + (INITIAL_MAP_U_DISTANCE_FROM_ORIGIN * 2) + 0;
			
			indices_index += 2;
			
			if (u_coord <= -INITIAL_MAP_U_DISTANCE_FROM_ORIGIN + 2 || v_coord <= -INITIAL_MAP_V_DISTANCE_FROM_ORIGIN + 2): continue;
			if (u_coord >= INITIAL_MAP_U_DISTANCE_FROM_ORIGIN - 2 || v_coord >= INITIAL_MAP_V_DISTANCE_FROM_ORIGIN - 2): continue;
			
			if ((indices_index % (INITIAL_MAP_U_DISTANCE_FROM_ORIGIN * 2) + 0) == 0): continue;
			
			indices.append(index_1);
			indices.append(index_2);
	
	# normals
	normals.resize(vertices.size());
	
	for i in range(normals.size()):
		
		normals[i] = Vector3(0, 0, 0);
	
	for i in range(0, indices.size(), 2):
		
		if (i + 2 >= indices.size()): continue;
		
		var index_1 = indices[i + 0];
		var index_2 = indices[i + 1];
		var index_3 = indices[i + 2];
		
		if (index_1 == index_2 or index_2 == index_3 or index_3 == index_1): pass;
		if (index_1 >= vertices.size() - 1 || index_2 >= vertices.size() - 1 || index_3 >= vertices.size() - 1): break;
		if (index_1 >= indices.size() - 1 || index_2 >= indices.size() - 1 || index_3 >= indices.size() - 1): break;
		
		var vert_index_1 = vertices[index_1];
		var vert_index_2 = vertices[index_2];
		var vert_index_3 = vertices[index_3];
		
		var tangent = vert_index_3 - vert_index_1;
		var bitangent = vert_index_2 - vert_index_1;
		var normal_vert_a = tangent.cross(bitangent);
		
		normals[index_1] = normal_vert_a;
		normals[index_2] = normal_vert_a;
		normals[index_3] = normal_vert_a;
	
	for i in range(normals.size()):
		
		normals[i] = normals[i].normalized();

func vertices_to_mesh():
	
	var mesh_array = ArrayMesh.new();
	var mesh_data = [];
	
	mesh_data.resize(ArrayMesh.ARRAY_MAX);
	
	mesh_data[ArrayMesh.ARRAY_VERTEX] = vertices;
	mesh_data[ArrayMesh.ARRAY_TEX_UV] = uvs;
	mesh_data[ArrayMesh.ARRAY_NORMAL] = normals;
	mesh_data[ArrayMesh.ARRAY_INDEX] = indices;
	
	mesh_array.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, mesh_data);
	
	mesh_instance = get_node(NodePath("ground_terrain").get_as_property_path());
	
	mesh_instance.mesh = mesh_array;
	
	#mesh_instance.create_trimesh_collision();

func _ready():
	
	print_debug("STARTING _ready()");
	
	initialize_terrain_generator();
	
	generate_terrain();
	
	vertices_to_mesh();
	
	print_debug("COMPLETED _ready()");
