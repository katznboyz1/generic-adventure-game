extends MeshInstance

func _ready():
	
	var mdt = MeshDataTool.new();
	
	var mesh = self.get_mesh();
	
	mdt.create_from_surface(mesh, 0);
	
	for vert in range(mdt.get_vertex_count()):
		
		var current_vert = mdt.get_vertex(vert);
		
		if (current_vert.y > 20):
			
			mdt.set_vertex_color(vert, Color(1, 1, 1));
		
		else:
			
			mdt.set_vertex_color(vert, Color(.5, .5, .5));
	
	mdt.commit_to_surface(self.mesh);
	mdt.clear();
