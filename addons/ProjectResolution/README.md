![Image](https://img.itch.zone/aW1hZ2UvMTM3ODU2OC84MDI4MDExLnBuZw==/original/ZQ1nVq.png)

# Godot Plugin Project Resolution (for Godot 4.x)

Godot plugin to quickly change and test Project Resolution settings.

Useful to test and prevent your UI from being inconsistent in different resolutions.

## Download

- Install from the Godot Asset Library at https://godotengine.org/asset-library/asset/9270
- or clone github repository at https://github.com/Danim3D/Godot-4-Plugin-Project-Resolution


## Installation

- Copy the contents of the "addons" directory to the "addons" directory of your Godot Project
- Go in "Project -> Project Settings -> Plugins (tab)" and enable "ProjectResolution"


## Usage

Once the plugin is activated, a new button will show up on the Top-Right corner of the Godot Editor, above the Inspector tab.
On use, the name of the button "Project Resolution" will be renamed by the selected resolution.

- "Fullscreen" will toggle the Fullscreen setting from the Projects Settings.
- "Play on Change" will play your main project scene when you change the resolution with the plugin.
- "Play Current Scene" will use the current opened scene instead of the main project settings scene.
- "Native" will use the current resolution of your desktop.
- "Landscape" will switch mobile resolutions using Landscape instead of Portrait.
- Custom resolutions can be added in the list of resolutions inside the plugin.gd file.
