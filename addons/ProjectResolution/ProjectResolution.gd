@tool
extends EditorPlugin

const POPUP_BUTTON_TEXT = "Project Resolution"
const MENU_BUTTON_TOOLTIP = "Quickly change and test different Project Resolution settings"
const PLUGIN_SELF_NAME = "ProjectResolution" #this variable must match the name of the plugin

var _plugin_menu_btn = MenuButton.new()
var _plugins_menu = _plugin_menu_btn.get_popup()

var _menu_items_idx = 0
var play_on_change = false
var play_current_scene = false
var multistart = false
var landscape = false

func _enter_tree():
	# Initialization
	_plugin_menu_btn.text = POPUP_BUTTON_TEXT
	_plugin_menu_btn.tooltip_text = MENU_BUTTON_TOOLTIP
	_plugin_menu_btn.icon = get_editor_interface().get_base_control().get_theme_icon("Viewport", "EditorIcons")

	_populate_menu()

	_plugins_menu.index_pressed.connect(_item_toggled.bind(_plugins_menu))
	_plugin_menu_btn.about_to_popup.connect(_refresh_plugins_menu_list)
	
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_menu_btn)


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_menu_btn)
	if _plugin_menu_btn:
		_plugin_menu_btn.free()


func _item_toggled(id, menuBtn) -> void:
	var is_item_checked = menuBtn.is_item_checked(id)
	_plugins_menu.set_item_checked(id, not is_item_checked)
	
	_set_resolution(id)
	
	_refresh_plugins_menu_list()


func _refresh_plugins_menu_list() -> void:
	_plugins_menu.clear()
	_menu_items_idx = 0
	_populate_menu()


func _populate_menu() -> void:
	var current_fullscreen = ProjectSettings.get_setting("display/window/size/mode")
#	print("fullscreen status: "+ str(current_fullscreen))
	var current_res = str(ProjectSettings.get_setting("display/window/size/viewport_width"))+"x"+str(ProjectSettings.get_setting("display/window/size/viewport_height"))
#	print("current_res: " + current_res)
	
	#by default added buttons are unchecked unless true
	var isPluginEnabled = false
	
	#Add Button settings
	var _buttons = ["Fullscreen", "Play On Change", "Play Current Scene", "Multistart"]
	for button in _buttons:
		isPluginEnabled = false
		if button == "Fullscreen" and current_fullscreen == 3:
			isPluginEnabled = true
		if button == "Play On Change" and play_on_change == true:
			isPluginEnabled = true
		if button == "Play Current Scene" and play_current_scene == true:
			isPluginEnabled = true
		if button == "Multistart" and multistart == true:
			isPluginEnabled = true

		_plugins_menu.add_check_item(button)
		_plugins_menu.set_item_checked(_menu_items_idx, isPluginEnabled)
		_menu_items_idx += 1
	
	#Add desktop resolutions
	_plugins_menu.add_separator("Desktop");
	_menu_items_idx += 1
	
	var _resolutions = ["Native", "2560x1600", "2560x1440", "1920x1200", "1920x1080", "1600x1200", "1280x1024", "1280x720", "1024x768", "800x600", "720x405", "640x480", "640x360","320x240"]
	for resolution in _resolutions:
		isPluginEnabled = false
		if resolution == current_res:
			isPluginEnabled = true
		
		#Hide or skip if resolution is larger than desktop resolution
		if resolution != "Native":
			var res = resolution.split("x")
			if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
				continue
		
		_plugins_menu.add_check_item(resolution)
		_plugins_menu.set_item_checked(_menu_items_idx, isPluginEnabled)
		_menu_items_idx += 1
	
	#Add widescreen resolutions
	_plugins_menu.add_separator("Widescreen");
	_menu_items_idx += 1
	
	var _widescreen_resolutions = ["5120x1440", "3840x1080", "2560x1080", "2560x720", "1920x540", "1280x360"]
	for resolution in _widescreen_resolutions:
		isPluginEnabled = false
		if resolution == current_res:
			isPluginEnabled = true
		
		#Hide or skip if resolution is larger than desktop resolution
		var res = resolution.split("x")
		if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
			continue
		
		_plugins_menu.add_check_item(resolution)
		_plugins_menu.set_item_checked(_menu_items_idx, isPluginEnabled)
		_menu_items_idx += 1
	
	#Add mobile resolutions
	_plugins_menu.add_separator("Mobile");
	_menu_items_idx += 1
	
	var buttonLandscape = "Landscape"
	if landscape == true:
		isPluginEnabled = true
	_plugins_menu.add_check_item(buttonLandscape)
	_plugins_menu.set_item_checked(_menu_items_idx, isPluginEnabled)
	_menu_items_idx += 1
	
	var _mobile_resolutions = ["1536x2048", "768x1024", "1242x2208", "1080x1920", "768x1280", "750x1334", "640x1136", "640x960", "480x800", "390x844", "375x667", "414x896", "375x812", "320x640", "320x480"]
	for resolution in _mobile_resolutions:
		isPluginEnabled = false
		if resolution == current_res:
			isPluginEnabled = true
		if landscape == true:
			var res = resolution.split("x")
			resolution = res[1]+"x"+res[0]
		
		#Hide or skip if resolution is larger than desktop resolution
		var res = resolution.split("x")
		if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
			continue
		
		_plugins_menu.add_check_item(resolution)
		_plugins_menu.set_item_checked(_menu_items_idx, isPluginEnabled)
		_menu_items_idx += 1


func _set_resolution(id) -> void:
	var is_item_checked = _plugins_menu.is_item_checked(id)
#	print(str(id) + " , " + _plugins_menu.get_item_text(id) + " , " + str(is_item_checked))
	
	_plugins_menu.set_item_checked(id, not is_item_checked)
	
	var item_name = _plugins_menu.get_item_text(id)
	if item_name == "Fullscreen":
		#Set Project Fullscreen setting
		var current_win = ProjectSettings.get_setting("display/window/size/mode")
		if current_win == 0:
			ProjectSettings.set_setting("display/window/size/mode", 3)
		else:
			ProjectSettings.set_setting("display/window/size/mode", 0)
		print("Fullscreen: "+str(ProjectSettings.get_setting("display/window/size/mode")))
	elif item_name == "Play On Change":
		play_on_change = !play_on_change
		print("Play On Change: "+str(play_on_change))
	elif item_name == "Play Current Scene":
		play_current_scene = !play_current_scene
		print("Play Current Scene: "+str(play_current_scene))
	elif item_name == "Multistart":
		multistart = !multistart
		print("Multistart: "+str(multistart))
	elif item_name == "Landscape":
		landscape = !landscape
		print("Landscape: "+str(landscape))
	else:
		#Set Project Resolution settings
		if item_name == "Native":
			item_name = str(DisplayServer.screen_get_size().x) + "x" + str(DisplayServer.screen_get_size().y)
		
		var res = item_name.split("x")
		ProjectSettings.set_setting("display/window/size/viewport_width", res[0])
		ProjectSettings.set_setting("display/window/size/viewport_height", res[1])
		print("Set Project Resolution: " + str(ProjectSettings.get_setting("display/window/size/viewport_width"))+"x"+str(ProjectSettings.get_setting("display/window/size/viewport_height")))
		
		#Update menu button name by resolution
		_plugin_menu_btn.text = item_name
		
		if play_on_change and !play_current_scene and !multistart:
			get_editor_interface().play_main_scene()
		if play_on_change and play_current_scene and !multistart:
			get_editor_interface().play_current_scene()
		else:
			if multistart:
				#if multistart is true, set to window mode instead of fullscreen
				ProjectSettings.set_setting("display/window/size/mode", 0)
				#if multistart is true, set play_current_scene to false
				play_current_scene = false
		if multistart and ProjectSettings.get_setting("display/window/size/mode") == 0:
			#start 2 window instance
			var spacing = 2
			var window_pos = Vector2(int(DisplayServer.screen_get_size().x)/2 - int(res[0])-spacing, int(DisplayServer.screen_get_size().y)/2 - int(res[1])/2)
			OS.create_process(OS.get_executable_path(), ["--path", ".", "--position", window_pos, false])
			window_pos = Vector2(int(DisplayServer.screen_get_size().x)/2+spacing, int(DisplayServer.screen_get_size().y)/2 - int(res[1])/2)
			OS.create_process(OS.get_executable_path(), ["--path", ".", "--position", window_pos, false])
	
	ProjectSettings.save()
	
	_refresh_plugins_menu_list()
