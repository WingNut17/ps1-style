@tool
extends EditorImportPlugin

const PS1_SHADER: ShaderMaterial = preload("res://resources/meshes/ps1_shadermaterial.tres")

func _get_importer_name():
	return "ps1_fbx_importer"

func _get_visible_name():
	return "PS1 FBX Importer"

func _get_recognized_extensions():
	return ["fbx"]

func _get_save_extension():
	return "scn"

func _get_resource_type():
	return "PackedScene"

func _get_preset_count():
	return 1

func _get_preset_name(preset_index):
	return "Default"

func _get_import_options(path, preset_index):
	return [
		{
			"name": "preserve_original_materials",
			"default_value": false,
			"property_hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		},
		{
			"name": "apply_root_scale",
			"default_value": true,
			"property_hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		},
		{
			"name": "root_scale",
			"default_value": 1.0,
			"property_hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.01,100,0.01"
		}
	]

func _get_option_visibility(path, option_name, options):
	if option_name == "root_scale":
		return options.get("apply_root_scale", true)
	return true

func _import(source_file, save_path, options, platform_variants, gen_files):
	# Use Godot's built-in FBX import system
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	
	# Try to import the FBX file
	var error = gltf_doc.append_from_file(source_file, gltf_state)
	if error != OK:
		push_error("Failed to import FBX file: " + source_file)
		return error
	
	# Generate the scene from GLTF data
	var scene_node = gltf_doc.generate_scene(gltf_state)
	if scene_node == null:
		push_error("Failed to generate scene from FBX file")
		return FAILED
	
	# Apply root scale if requested
	if options.get("apply_root_scale", true):
		var scale_factor = options.get("root_scale", 1.0)
		if scale_factor != 1.0:
			scene_node.scale = Vector3.ONE * scale_factor
	
	# Process all mesh instances and replace materials
	_process_node_materials(scene_node, options)
	
	# Create the final packed scene
	var final_scene = PackedScene.new()
	final_scene.pack(scene_node)
	
	# Save the final scene
	var save_result = ResourceSaver.save(final_scene, save_path + "." + _get_save_extension())
	
	return save_result

func _process_node_materials(node: Node, options: Dictionary):
	# Process current node if it's a MeshInstance3D
	if node is MeshInstance3D:
		_replace_mesh_materials(node, options)
	
	# Recursively process all children
	for child in node.get_children():
		_process_node_materials(child, options)

func _replace_mesh_materials(mesh_instance: MeshInstance3D, options: Dictionary):
	var mesh = mesh_instance.mesh
	if mesh == null:
		return
	
	# Get the number of surfaces in the mesh
	var surface_count = mesh.get_surface_count()
	
	for i in range(surface_count):
		var original_material = mesh.surface_get_material(i)
		
		# Check if we should preserve original materials
		if options.get("preserve_original_materials", false) and original_material != null and _should_preserve_material(original_material):
			continue
		
		# Extract the albedo texture from the original material
		var albedo_texture = null
		if original_material != null:
			albedo_texture = _extract_albedo_texture(original_material)
		
		# Create new PS1 material with the extracted texture
		var new_material = _create_ps1_material(albedo_texture, options)
		
		# Apply the new material to this surface
		mesh_instance.set_surface_override_material(i, new_material)
		
		print("Replaced material on surface ", i, " of ", mesh_instance.name, 
			  " with texture: ", albedo_texture.resource_path if albedo_texture else "none")

func _should_preserve_material(material: Material) -> bool:
	# Don't replace if it's already using the PS1 shader
	if material is ShaderMaterial:
		var shader_mat = material as ShaderMaterial
		if shader_mat.shader != null and shader_mat.shader == PS1_SHADER.shader:
			return true
	return false

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

func _create_ps1_material(albedo_texture: Texture2D, options: Dictionary) -> ShaderMaterial:
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
		print("Applied albedo texture: ", albedo_texture.resource_path if albedo_texture.resource_path != "" else "embedded texture")
	else:
		print("No albedo texture found in original material")
	
	return new_material
