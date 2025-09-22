@tool
extends EditorScenePostImport

const PS1_SHADER: ShaderMaterial = preload("res://resources/meshes/ps1_shadermaterial_map_no_cull.tres")

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
		
		# Extract both texture and color from the original material
		var albedo_texture = null
		var albedo_color = Color.WHITE
		
		if original_material != null:
			albedo_texture = _extract_albedo_texture(original_material)
			albedo_color = _extract_albedo_color(original_material)
		
		# Create new PS1 material with the extracted texture and color
		var new_material = _create_ps1_material(albedo_texture, albedo_color)
		
		# Apply the new material to this surface
		mesh_instance.set_surface_override_material(i, new_material)
		
		print("PS1 Post-Import: Replaced material on surface ", i, " of ", mesh_instance.name, 
			  " with color: ", albedo_color)

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

func _extract_albedo_color(material: Material) -> Color:
	var color = Color.WHITE
	
	if material is StandardMaterial3D:
		var std_mat = material as StandardMaterial3D
		color = std_mat.albedo_color
	elif material is ShaderMaterial:
		var shader_mat = material as ShaderMaterial
		# Try common shader parameter names for albedo colors
		var possible_names = ["color_albedo", "albedo_color", "diffuse_color", "main_color", "color", "modulate"]
		for param_name in possible_names:
			var param_value = shader_mat.get_shader_parameter(param_name)
			if param_value is Color:
				color = param_value
				break
	
	return color

func _create_ps1_material(albedo_texture: Texture2D, albedo_color: Color) -> ShaderMaterial:
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
	
	# Always set the albedo color (even if we have a texture, the color can modulate it)
	new_material.set_shader_parameter("albedo", albedo_color)
	
	return new_material
