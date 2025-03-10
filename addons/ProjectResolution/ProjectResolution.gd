@tool
extends EditorPlugin

const POPUP_BUTTON_TEXT = "Project Resolution"
const MENU_BUTTON_TOOLTIP = "Quickly change and test different Project Resolution settings"
const PLUGIN_SELF_NAME = "ProjectResolution" #this variable must match the name of the plugin

var _plugin_menu_btn = MenuButton.new()
var _plugin_menu = _plugin_menu_btn.get_popup()

var _menu_items_idx = 0
var play_on_change = false
var play_current_scene = false
var multistart = false
var change_viewport = false
var landscape = false

func _enter_tree():
	# Initialization
	_plugin_menu_btn.text = POPUP_BUTTON_TEXT
	_plugin_menu_btn.tooltip_text = MENU_BUTTON_TOOLTIP
	_plugin_menu_btn.icon = get_editor_interface().get_base_control().get_theme_icon("Viewport", "EditorIcons")

	_populate_menu()

	_plugin_menu.index_pressed.connect(_item_toggled.bind(_plugin_menu))
	_plugin_menu_btn.about_to_popup.connect(_refresh_plugin_menu)
	
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_menu_btn)


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_menu_btn)
	if _plugin_menu_btn:
		_plugin_menu_btn.free()


func _item_toggled(id, menuBtn) -> void:
	var is_item_checked = menuBtn.is_item_checked(id)
	_plugin_menu.set_item_checked(id, not is_item_checked)
	
	_on_plugin_menu_index_pressed(id)
	
	_refresh_plugin_menu()


func _refresh_plugin_menu() -> void:
	_plugin_menu.clear()
	_menu_items_idx = 0
	_populate_menu()


func _populate_menu() -> void:
	#Get current ProjectSettings and resolution
	var current_fullscreen = ProjectSettings.get_setting("display/window/size/mode")
#	print("fullscreen status: "+ str(current_fullscreen))
	var current_res = str(ProjectSettings.get_setting("display/window/size/window_width_override"))+"x"+str(ProjectSettings.get_setting("display/window/size/window_height_override"))
#	print("current_res: " + current_res)
	var current_viewport_res = str(ProjectSettings.get_setting("display/window/size/viewport_width"))+"x"+str(ProjectSettings.get_setting("display/window/size/viewport_height"))
#	print("current_viewport_res: " + current_viewport_res)

	#Reset submenu
	var submenu = PopupMenu.new()
	submenu.add_item("Reset All")
	submenu.add_item("Reset Mode")
	submenu.add_item("Reset Window Size")
	submenu.add_item("Reset Viewport Size")
	submenu.index_pressed.connect(_on_reset_index_pressed.bind(submenu))
	_plugin_menu.add_submenu_node_item("Reset", submenu)
	_menu_items_idx += 1
	
	#by default added buttons are unchecked unless true
	var isCheckEnabled = false
	
	#Add Button settings
	var _buttons = ["Fullscreen", "Play On Change", "Play Current Scene", "Multistart", "Landscape"]
	var _resolutions = ["Native", "2560x1600", "2560x1440", "1920x1200", "1920x1080", "1600x1200", "1280x1024", "1280x720", "1024x768", "800x600", "720x405", "640x480", "640x360","320x240"]
	var _widescreen_resolutions = ["5120x1440", "3840x1080", "2560x1080", "2560x720", "1920x540", "1280x360"]
	var _mobile_resolutions = ["1536x2048", "768x1024", "1242x2208", "1080x1920", "768x1280", "750x1334", "640x1136", "640x960", "480x800", "390x844", "375x667", "414x896", "375x812", "320x640", "320x480"]
	for button in _buttons:
		isCheckEnabled = false
		if button == "Fullscreen" and current_fullscreen == 3:
			isCheckEnabled = true
		if button == "Play On Change" and play_on_change == true:
			isCheckEnabled = true
		if button == "Play Current Scene" and play_current_scene == true:
			isCheckEnabled = true
		if button == "Multistart" and multistart == true:
			isCheckEnabled = true
		if button == "Landscape" and landscape == true:
			isCheckEnabled = true
		
		_plugin_menu.add_check_item(button)
		_plugin_menu.set_item_checked(_menu_items_idx, isCheckEnabled)
		_menu_items_idx += 1
	
	#Viewport Resolution
	var submenuViewportRes = PopupMenu.new()
	submenuViewportRes.add_separator("Current Viewport "+current_viewport_res);
	submenuViewportRes.add_separator("Desktop");
	var v_idx = 2
	for resolution in _resolutions:
		#submenuViewportRes.add_item(resolution)
		isCheckEnabled = false
		if resolution == current_viewport_res:
			isCheckEnabled = true
		#Hide or skip if resolution is larger than desktop resolution
		if resolution != "Native":
			var res = resolution.split("x")
			if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
				continue
		submenuViewportRes.add_check_item(resolution)
		submenuViewportRes.set_item_checked(v_idx, isCheckEnabled)
		v_idx += 1
	submenuViewportRes.add_separator("Widescreen");
	v_idx += 1
	for resolution in _widescreen_resolutions:
		#submenuViewportRes.add_item(resolution)
		isCheckEnabled = false
		if resolution == current_viewport_res:
			isCheckEnabled = true
		#Hide or skip if resolution is larger than desktop resolution
		var res = resolution.split("x")
		if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
			continue
		submenuViewportRes.add_check_item(resolution)
		submenuViewportRes.set_item_checked(v_idx, isCheckEnabled)
		v_idx += 1
	submenuViewportRes.add_separator("Mobile");
	v_idx += 1
	for resolution in _mobile_resolutions:
		#submenuViewportRes.add_item(resolution)
		#Landscape
		if landscape == true:
			var res = resolution.split("x")
			resolution = res[1]+"x"+res[0]
		#Hide or skip if resolution is larger than desktop resolution
		var res = resolution.split("x")
		if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
			continue
		isCheckEnabled = false
		if resolution == current_viewport_res:
			isCheckEnabled = true
		submenuViewportRes.add_check_item(resolution)
		submenuViewportRes.set_item_checked(v_idx, isCheckEnabled)
		v_idx += 1
	submenuViewportRes.index_pressed.connect(_on_set_viewport_resolution_index_pressed.bind(submenuViewportRes))
	#_plugin_menu.add_submenu_node_item("Viewport Resolution", submenuViewportRes)
	_plugin_menu.add_submenu_node_item("Viewport Resolution "+current_viewport_res, submenuViewportRes)
	#submenuViewportRes.name = "Viewport Resolution "+current_viewport_res
	_menu_items_idx += 1
	
	#Window Override Resolution
	var submenuProjectRes = PopupMenu.new()
	submenuProjectRes.add_separator("Current Window Override Resolution "+current_res);
	submenuProjectRes.add_separator("Desktop");
	var o_idx = 2
	for resolution in _resolutions:
		isCheckEnabled = false
		if resolution == current_res:
			isCheckEnabled = true
		#Hide or skip if resolution is larger than desktop resolution
		if resolution != "Native":
			var res = resolution.split("x")
			if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
				continue
		submenuProjectRes.add_check_item(resolution)
		submenuProjectRes.set_item_checked(o_idx, isCheckEnabled)
		o_idx += 1
	submenuProjectRes.add_separator("Widescreen");
	o_idx += 1
	for resolution in _widescreen_resolutions:
		isCheckEnabled = false
		if resolution == current_res:
			isCheckEnabled = true
		#Hide or skip if resolution is larger than desktop resolution
		var res = resolution.split("x")
		if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
			continue
		submenuProjectRes.add_check_item(resolution)
		submenuProjectRes.set_item_checked(o_idx, isCheckEnabled)
		o_idx += 1
	submenuProjectRes.add_separator("Mobile");
	o_idx += 1
	for resolution in _mobile_resolutions:
		#Landscape
		if landscape == true:
			var res = resolution.split("x")
			resolution = res[1]+"x"+res[0]
		#Hide or skip if resolution is larger than desktop resolution
		var res = resolution.split("x")
		if int(res[0]) > DisplayServer.screen_get_size().x or int(res[1]) > DisplayServer.screen_get_size().y:
			continue
		isCheckEnabled = false
		if resolution == current_res:
			isCheckEnabled = true
		submenuProjectRes.add_check_item(resolution)
		submenuProjectRes.set_item_checked(o_idx, isCheckEnabled)
		o_idx += 1
	submenuProjectRes.index_pressed.connect(_on_set_override_resolution_index_pressed.bind(submenuProjectRes))
	#_plugin_menu.add_submenu_node_item("Project Resolution", submenuProjectRes)
	_plugin_menu.add_submenu_node_item("Window Override Resolution "+current_res, submenuProjectRes)
	#submenuProjectRes.name = "Project Resolution "+current_res
	_menu_items_idx += 1


func reset_all():
	reset_mode()
	reset_window_size()
	reset_viewport_size()
	play_on_change = false
	play_current_scene = false
	multistart = false
	landscape = false

func reset_mode():
	ProjectSettings.set_setting("display/window/size/mode", 0)
	print("Reset Mode: Windowed")
	_refresh_plugin_menu()

func reset_window_size():
	ProjectSettings.set_setting("display/window/size/window_width_override", 0)
	ProjectSettings.set_setting("display/window/size/window_height_override", 0)
	_plugin_menu_btn.text = POPUP_BUTTON_TEXT
	#_plugin_menu_btn.text = str(ProjectSettings.get_setting("display/window/size/window_width_override"))+"x"+str(ProjectSettings.get_setting("display/window/size/window_height_override"))
	print("Reset Window Size: " + str(ProjectSettings.get_setting("display/window/size/window_width_override"))+"x"+str(ProjectSettings.get_setting("display/window/size/window_height_override")))
	_refresh_plugin_menu()

func reset_viewport_size():
	ProjectSettings.set_setting("display/window/size/viewport_width", 1152)
	ProjectSettings.set_setting("display/window/size/viewport_height", 648)
	print("Reset Viewport Size: " + str(ProjectSettings.get_setting("display/window/size/viewport_width"))+"x"+str(ProjectSettings.get_setting("display/window/size/viewport_height")))
	_refresh_plugin_menu()

func _on_reset_index_pressed(index:int, menu:PopupMenu) -> void:
	#print('Menu: %s index: %s id: %s text: %s' % [menu.name, index, menu.get_item_id(index), menu.get_item_text(index)])
	var menuItem = menu.get_item_text(index)
	if menuItem == "Reset All":
		reset_all()
	elif menuItem == "Reset Mode":
		reset_mode()
	elif menuItem == "Reset Window Size":
		reset_window_size()
	elif menuItem == "Reset Viewport Size":
		reset_viewport_size()


func _update_menu_button_name():
		_plugin_menu_btn.text = "Viewport: " + str(ProjectSettings.get_setting("display/window/size/viewport_width"))+"x"+str(ProjectSettings.get_setting("display/window/size/viewport_height") + "  Override: "+ str(ProjectSettings.get_setting("display/window/size/window_width_override"))+"x"+str(ProjectSettings.get_setting("display/window/size/window_height_override")))


func _on_set_viewport_resolution_index_pressed(index:int, menu:PopupMenu) -> void:
	#print('Menu: %s index: %s id: %s text: %s' % [menu.name, index, menu.get_item_id(index), menu.get_item_text(index)])
	var menuItem = menu.get_item_text(index)
	
	#Get Native Resolution
	if menuItem == "Native":
		menuItem = str(DisplayServer.screen_get_size().x) + "x" + str(DisplayServer.screen_get_size().y)
	
	#Viewport Resolution
	var res = menuItem.split("x")
	ProjectSettings.set_setting("display/window/size/viewport_width", res[0])
	ProjectSettings.set_setting("display/window/size/viewport_height", res[1])
	print("Set Viewport Resolution: " + str(ProjectSettings.get_setting("display/window/size/viewport_width"))+"x"+str(ProjectSettings.get_setting("display/window/size/viewport_height")))
	
	_play_on_change(res)
	_update_menu_button_name()
	_refresh_plugin_menu()


func _on_set_override_resolution_index_pressed(index:int, menu:PopupMenu) -> void:
	#print('Menu: %s index: %s id: %s text: %s' % [menu.name, index, menu.get_item_id(index), menu.get_item_text(index)])
	var menuItem = menu.get_item_text(index)
	
	#Get Native Resolution
	if menuItem == "Native":
		menuItem = str(DisplayServer.screen_get_size().x) + "x" + str(DisplayServer.screen_get_size().y)
	
	#Project Resolution
	var res = menuItem.split("x")
	ProjectSettings.set_setting("display/window/size/window_width_override", res[0])
	ProjectSettings.set_setting("display/window/size/window_height_override", res[1])
	print("Set Project Resolution: " + str(ProjectSettings.get_setting("display/window/size/window_width_override"))+"x"+str(ProjectSettings.get_setting("display/window/size/window_height_override")))
	
	_play_on_change(res)
	_update_menu_button_name()
	_refresh_plugin_menu()


func _play_on_change(res):
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


func _on_plugin_menu_index_pressed(id) -> void:
	var is_item_checked = _plugin_menu.is_item_checked(id)
#	print(str(id) + " , " + _plugin_menu.get_item_text(id) + " , " + str(is_item_checked))
	
	_plugin_menu.set_item_checked(id, not is_item_checked)
	
	var item_name = _plugin_menu.get_item_text(id)
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
	
	ProjectSettings.save()
