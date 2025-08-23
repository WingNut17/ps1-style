@tool
extends EditorScenePostImport

const PS1_SHADER: ShaderMaterial = preload("res://resources/meshes/ps1_shadermaterial.tres")

# This function is called after a 3D scene is imported
func _post_import(scene):
	print("PS1 Post-Import: Processing scene...")
	_process_node_materials(scene)
	return scene

func _process_node_materials(node: Node):
	# Process current node if it's a MeshInstance3D
	if node is MeshInstance3D:
		_replace_mesh_materials(node)
	
	# Recursively process all children
	for child in node.get_children():
		_process_node_materials(child)

func _replace_mesh_materials(mesh_instance: MeshInstance3D):
	var mesh = mesh_instance.mesh
	if mesh == null:
		return
	
	# Get the number of surfaces in the mesh
	var surface_count = mesh.get_surface_count()
	
	for i in range(surface_count):
		var original_material = mesh.surface_get_material(i)
		
		# Extract the albedo texture from the original material
		var albedo_texture = null
		if original_material != null:
			albedo_texture = _extract_albedo_texture(original_material)
		
		# Create new PS1 material with the extracted texture
		var new_material = _create_ps1_material(albedo_texture)
		
		# Apply the new material to this surface
		mesh_instance.set_surface_override_material(i, new_material)
		
		print("PS1 Post-Import: Replaced material on surface ", i, " of ", mesh_instance.name)

func _extract_albedo_texture(material: Material) -> Texture2D:
	var texture: Texture2D = null
	
	if material is StandardMaterial3D:
		var std_mat = material as StandardMaterial3D
		texture = std_mat.albedo_texture
	elif material is ShaderMaterial:
		var shader_mat = material as ShaderMaterial
		# Try common shader parameter names for albedo textures
		var possible_names = ["texture_albedo", "albedo_texture", "diffuse_texture", "main_texture", "texture"]
		for param_name in possible_names:
			var param_value = shader_mat.get_shader_parameter(param_name)
			if param_value is Texture2D:
				texture = param_value
				break
	
	return texture

func _create_ps1_material(albedo_texture: Texture2D) -> ShaderMaterial:
	# Create a new instance of the PS1 shader material
	var new_material = ShaderMaterial.new()
	new_material.shader = PS1_SHADER.shader
	
	# Copy all shader parameters from the template material
	if PS1_SHADER.shader != null:
		var shader_params = PS1_SHADER.shader.get_shader_uniform_list()
		for param in shader_params:
			var param_name = param.name
			var template_value = PS1_SHADER.get_shader_parameter(param_name)
			if template_value != null:
				new_material.set_shader_parameter(param_name, template_value)
	
	# Set the albedo texture if we found one
	if albedo_texture != null:
		new_material.set_shader_parameter("texture_albedo", albedo_texture)
		print("PS1 Post-Import: Applied albedo texture: ", 
			  albedo_texture.resource_path if albedo_texture.resource_path != "" else "embedded texture")
	
	return new_material
