# HTTP Request library
A visionary render plugin to ease the creation of Rules for a [Virtalis Reach](https://www.virtalis.com/products/virtalis-reach) Project.

Makes use of this JSON Lua library for encoding: https://github.com/rxi/json.lua

## Installation
To install the plugin, download this repository and use Settings -> Plugins -> Add Plugin to install it into Visionary Render.

If you are unable to directly import the .zip, you may need to extract the contents to `(documents dir)/Visionary Render <version>/plugins` and make sure the outer folder is called "**reachtemplaterules**".

## Usage
Once installed this plugin will add a 'Reach' context menu option when right-clicking anything in the Scenes tree or in the 3D scene itself.

### Create Delete Nodes Rule

For all node types there will be a context menu option to 'Create Delete Nodes Rule'. Once clicked, a rule for deleting the selected node will be printed to the log. *(Ctrl+D to open Diagnostics, select 'Log' tab)*

### Create Change Property Rule

For Assemblies and Materials there will be a 'Create Change Property Rule' context menu option too, with a sub-menu to choose a property to create a rule for. The current value of the chosen property will be used to create the rule, so make any modifications you would like to see in the final Visualization before creating the rule.

Again, the JSON of the rule will be printed to the Log for you to Copy.


## License
MIT