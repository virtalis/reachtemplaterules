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

-- Definition of a ChangePropertyRule, used to serialize to json
ChangePropertyRule = {
  Type = "ChangePropertyRule",
  Pattern = "",
  PropertyName = "property-name",
  Value = ""
}

local function version()
  return "0.2.0"
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

-- Adds Create Change Property context menu option for every property of a metanode to
-- Adds a context menu option to create an array of json rules for ALL PROPERTIES on a node
local function addContextForMetanode(metanodeType)
  propCount = vrMetaNodeGetPropertyCount(metanodeType)

  for i=0, propCount-1, 1 do
    local name, type, description, canBeSaved, elements = vrMetaNodeGetPropertyByIndex(metanodeType, i)

    addCtx(modname .. ".contextPropertyUpdate", name, name, metanodeType, g_changePropertyContextContainer, "Generate a " .. name .. " property change rule for this node", nil, nil, nil, "Edit")
  end

  -- Adds a context menu option named "ALL PROPERTIES" which will create a json array of rules for every single property in one go.
  addCtx(modname .. ".contextGenerateRuleForAllProperties", "ALL PROPERTIES", metanodeType, metanodeType, g_changePropertyContextContainer, "Generate property update rule for all properties on this node", nil, nil, nil, "Edit")
end

-- Initialize the context menu node for creating a ChangePropertyRule
local function initChangePropertyNodeContext()
  print(name(), "Initializing Change Property Context Menu")

  g_changePropertyContextContainer = addCtx(nil, "Create Change Property Rule", nil, nil, g_reachContextMenu, nil, nil, nil)

  addContextForMetanode("Light")
  addContextForMetanode("StdMaterial")
  addContextForMetanode("Assembly")
  addContextForMetanode("Visual")
  addContextForMetanode("GUI")
  addContextForMetanode("Stack")
  addContextForMetanode("Billboard")
  addContextForMetanode("Button")
  addContextForMetanode("Label")
  addContextForMetanode("Panel")
  addContextForMetanode("EventHandler")
  addContextForMetanode("Script")
  addContextForMetanode("Sequence")
  addContextForMetanode("AssemblyTrack")
  addContextForMetanode("Animation")
  addContextForMetanode("AnimationFramePRS")
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

-- Callback for a Create Change Property Rule context menu option on a Material.
-- Prints the json-ified rule to the log.
local function contextPropertyUpdate(node, propertyName)
  rule = ChangePropertyRule
  rule.Pattern = getNodePathAsRulePattern(node)
  rule.PropertyName = propertyName
  rule.Value = tostring(vrNodeGetValue(node, propertyName)):gsub(',', '')
  ruleJson = json.encode(rule)
  print(ruleJson)
end

-- Callback to create an array of Change Property Rules for every property on a node
local function contextGenerateRuleForAllProperties(node, metanode)
  rules = {}  

  propCount = vrMetaNodeGetPropertyCount(metanode)

  for i=0, propCount-1, 1 do
    local propName, type, description, canBeSaved, elements = vrMetaNodeGetPropertyByIndex(metanode, i)
    newRule = ChangePropertyRule
    newRule.Pattern = getNodePathAsRulePattern(node)
    newRule.PropertyName = propName
    newRule.Value = tostring(vrNodeGetValue(node, propName)):gsub(',', '')
    ruleJson = json.encode(newRule) 
    rules[i] = ruleJson
  end

  rulesJsonString = "["

  for i=0, propCount-1, 1 do
    rulesJsonString = rulesJsonString .. rules[i]

    if i ~= propCount-1 then
      rulesJsonString = rulesJsonString .. ","
    end
  end

  rulesJsonString = rulesJsonString .. "]"

  print(rulesJsonString)
end

-- Export the plugin functions to the Lua state.
return {
  name = name,
  version = version,
  init = init,
  cleanup = cleanup,
  createDeleteNodesRuleCallback = createDeleteNodesRuleCallback,
  contextPropertyUpdate = contextPropertyUpdate,
  contextGenerateRuleForAllProperties = contextGenerateRuleForAllProperties
}