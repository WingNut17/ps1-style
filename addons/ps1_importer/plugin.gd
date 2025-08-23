@tool
extends EditorPlugin

const PS1FBXImporter = preload("res://addons/ps1_importer/ps1_fbx_importer.gd")
var importer_plugin

func _enter_tree():
	importer_plugin = PS1FBXImporter.new()
	add_import_plugin(importer_plugin)

func _exit_tree():
	remove_import_plugin(importer_plugin)
	importer_plugin = null
