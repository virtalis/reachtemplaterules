local json = require "json"
local addCtx = __addTreeViewContextOption

local g_reachContextMenu
local g_deleteNodesRuleContextMenu
local g_changePropertyContextContainer

local modname = "reachtemplaterules"
local function name()
  return "Reach - Template Rules"
end

-- Definition of a DeleteNodesRule, used to serialize to json
DeleteNodesRule = {
  Type = "DeleteNodesRule",
  Pattern = ""
}

-- Definition of a DeleteNodesRule, used to serialize to json
ChangePropertyRule = {
  Type = "ChangePropertyRule",
  Pattern = "",
  PropertyName = "property-name",
  Value = ""
}

local function version()
  return "0.1.0"
end

-- Initialize the context menu node for creating a DeleteNodesRule
local function initDeleteNodeContext()
  print(name(), " Initializing Delete Node Context Menu")
  
  -- create the entry directly - Lua operates in unversioned metanode names.
  g_deleteNodesRuleContextMenu = vrCreateNode("ApplicationMenuEntry", "DeleteNodesRuleMenuNode", g_reachContextMenu)
  g_deleteNodesRuleContextMenu.Caption = "Create Delete Nodes Rule"
  g_deleteNodesRuleContextMenu.Type = __ApplicationMenuEntry_TypeLua
  g_deleteNodesRuleContextMenu.Command = modname .. ".createDeleteNodesRuleCallback"
end

-- Initialize the context menu node for creating a ChangePropertyRule
local function initChangePropertyNodeContext()
  print(name(), "Initializing Change Property Context Menu")

  g_changePropertyContextContainer = addCtx(nil, "Create Change Property Rule", nil, nil, g_reachContextMenu, nil, nil, nil)

  -- Assembly
  addCtx(modname .. ".contextAssemblyEnabled", "Enabled", nil, "Assembly", g_changePropertyContextContainer, "Generate an enabled state rule for this assembly", nil, nil, nil, "Edit")
  
  -- Create Context Menu options for StdMaterial properties.
  addCtx(modname .. ".contextMaterialProperty", "Diffuse", "Diffuse", "StdMaterial", g_changePropertyContextContainer, "Generate a Diffuse property change rule for this material", nil, nil, nil, "Edit")
  addCtx(modname .. ".contextMaterialProperty", "Reflectivity", "Reflectivity", "StdMaterial", g_changePropertyContextContainer, "Generate a Reflectivity property change rule for this material", nil, nil, nil, "Edit")
  addCtx(modname .. ".contextMaterialProperty", "Smoothness", "Smoothness", "StdMaterial", g_changePropertyContextContainer, "Generate a Reflectivity property change rule for this material", nil, nil, nil, "Edit")
  addCtx(modname .. ".contextMaterialProperty", "Metalness", "Metalness", "StdMaterial", g_changePropertyContextContainer, "Generate a Metalness property change rule for this material", nil, nil, nil, "Edit")
  addCtx(modname .. ".contextMaterialProperty", "Ambient", "Ambient", "StdMaterial", g_changePropertyContextContainer, "Generate as Ambient property change rule for this material", nil, nil, nil, "Edit")
  addCtx(modname .. ".contextMaterialProperty", "Emissive", "Emissive", "StdMaterial", g_changePropertyContextContainer, "Generate an Emissive property change rule for this material", nil, nil, nil, "Edit")
  addCtx(modname .. ".contextMaterialProperty", "EmissiveIntensity", "EmissiveIntensity", "StdMaterial", g_changePropertyContextContainer, "Generate an EmissiveIntensity property change rule for this material", nil, nil, nil, "Edit")
  addCtx(modname .. ".contextMaterialProperty", "Opacity", "Opacity", "StdMaterial", g_changePropertyContextContainer, "Generate a Opacity property change rule for this material", nil, nil, nil, "Edit")
end

local function init()
  print("Init ", name())

  -- Create base context menu named 'Reach'
  g_reachContextMenu = addCtx(nil, "Reach", nil, nil, nil, nil, nil, nil)

  initDeleteNodeContext()
  initChangePropertyNodeContext()
end

local function cleanup()
  print("Cleanup ", name())
  vrDeleteNode(g_reachContextMenu)
end

-- Returns the nodes path as a 'reach-formatted' pattern
local function getNodePathAsRulePattern(node)
  curStringPattern = ""
  curNode = node
  while curNode and (curNode:type(false) ~= 'LibraryList') and (curNode:type(false) ~= 'SceneList') do
    curStringPattern = "/:" .. curNode:type(false) .. ";" .. curNode:getName() .. curStringPattern
    curNode = curNode:getParent()
  end
  return curStringPattern
end

-- EXPORTED FUNCTIONS
-- Callback for the g_deleteNodesRuleContextMenu context menu.
-- Prints the json-ified rule to the log.
local function createDeleteNodesRuleCallback(node)
  pattern = getNodePathAsRulePattern(node)
  
  rule = DeleteNodesRule
  rule.Pattern = pattern

  ruleJson = json.encode(rule)
  print(ruleJson)
end

-- Callback for the Change Property context menu option for the 'Enabled' property on Assembly nodes.
-- Prints the json-ified rule to the log.
local function contextAssemblyEnabled(node)
  rule = ChangePropertyRule
  rule.Pattern = getNodePathAsRulePattern(node)
  rule.PropertyName = "Enabled"
  rule.Value = node.Enabled == true and "1" or "0"

  ruleJson = json.encode(rule)
  print(ruleJson)
end

-- Callback for a Create Change Property Rule context menu option on a Material.
-- Prints the json-ified rule to the log.
local function contextMaterialProperty(node, propertyName)
  rule = ChangePropertyRule
  rule.Pattern = getNodePathAsRulePattern(node)
  rule.PropertyName = propertyName
  rule.Value = tostring(vrNodeGetValue(node, propertyName)):gsub(',', '')
  ruleJson = json.encode(rule)
  print(ruleJson)
end

-- Export the plugin functions to the Lua state.
return {
  name = name,
  version = version,
  init = init,
  cleanup = cleanup,
  createDeleteNodesRuleCallback = createDeleteNodesRuleCallback,
  contextAssemblyEnabled = contextAssemblyEnabled,
  contextMaterialProperty = contextMaterialProperty
}