include("PopupDialog");
include("TSLHugeAustralia");

local BLUEPRINT = MTB_TSL_HUGE_AUSTRALIA;
local ROLE_CITY = "city";
local ROLE_HARBOR = "harbor";
local ROLE_COMMERCIAL = "commercial";
local ICONS = {
  [ROLE_CITY] = "ICON_DISTRICT_CITY_CENTER",
  [ROLE_HARBOR] = "ICON_DISTRICT_HARBOR",
  [ROLE_COMMERCIAL] = "ICON_DISTRICT_COMMERCIAL_HUB",
};
local ROLE_KEYS = {
  [ROLE_CITY] = "LOC_MTB_ROLE_CITY",
  [ROLE_HARBOR] = "LOC_MTB_ROLE_HARBOR",
  [ROLE_COMMERCIAL] = "LOC_MTB_ROLE_COMMERCIAL",
};

local m_selectedCityCount = 8;
local m_buttonInstance = nil;
local m_buttonInjected = false;

local function CoordKey(x, y)
  return tostring(x) .. ":" .. tostring(y);
end

local function StartsWith(value, prefix)
  return value ~= nil and string.sub(value, 1, string.len(prefix)) == prefix;
end

local function SetActionStatus(text, isError)
  Controls.ActionStatus:SetText(text or "");
  if isError then
    Controls.ActionStatus:SetColor(UI.GetColorValue("COLOR_RED"));
  else
    Controls.ActionStatus:SetColor(UI.GetColorValue("COLOR_GREEN"));
  end
end

local function GetPlan(cityCount)
  for _, plan in ipairs(BLUEPRINT.plans) do
    if plan.cityCount == cityCount then
      return plan;
    end
  end
  return nil;
end

local function ValidateCurrentMap()
  local width, height = Map.GetGridSize();
  if width ~= BLUEPRINT.map.width or height ~= BLUEPRINT.map.height then
    return false, Locale.Lookup("LOC_MTB_MAP_WRONG_SIZE", width, height, BLUEPRINT.map.width, BLUEPRINT.map.height);
  end

  for _, anchor in ipairs(BLUEPRINT.map.anchors) do
    local plot = Map.GetPlot(anchor.x, anchor.y);
    local terrain = GameInfo.Terrains[anchor.terrain];
    if plot == nil or terrain == nil or plot:GetTerrainType() ~= terrain.Index then
      return false, Locale.Lookup("LOC_MTB_MAP_FINGERPRINT_FAILED");
    end
  end

  return true, Locale.Lookup("LOC_MTB_MAP_VALID");
end

local function MakePinName(cityIndex, cityLabel, role)
  return string.format("%s%02d %s·%s", BLUEPRINT.ownedNamePrefix, cityIndex, cityLabel, Locale.Lookup(ROLE_KEYS[role]));
end

local function AddDesiredPin(desired, cityIndex, cityLabel, role, coords)
  local pin = {
    x = coords.x,
    y = coords.y,
    icon = ICONS[role],
    name = MakePinName(cityIndex, cityLabel, role),
  };
  desired[CoordKey(pin.x, pin.y)] = pin;
end

local function BuildDesiredPins(cityCount)
  local desired = {};
  for cityIndex = 1, cityCount do
    local city = BLUEPRINT.cities[cityIndex];
    local label = Locale.Lookup(city.labelKey);
    AddDesiredPin(desired, cityIndex, label, ROLE_CITY, city.city);
    AddDesiredPin(desired, cityIndex, label, ROLE_HARBOR, city.harbor);
    AddDesiredPin(desired, cityIndex, label, ROLE_COMMERCIAL, city.commercialHub);
  end
  return desired;
end

local function NotifyDmtRemoved(pin)
  if LuaEvents.DMT_MapPinRemoved ~= nil then
    LuaEvents.DMT_MapPinRemoved(pin);
  end
end

local function NotifyDmtAdded(pin)
  if LuaEvents.DMT_MapPinAdded ~= nil then
    LuaEvents.DMT_MapPinAdded(pin);
  end
end

local function ImportSelectedPlan()
  local mapValid, mapMessage = ValidateCurrentMap();
  if not mapValid then
    SetActionStatus(mapMessage, true);
    return;
  end

  local localPlayer = Game.GetLocalPlayer();
  local playerConfig = PlayerConfigurations[localPlayer];
  if playerConfig == nil then
    SetActionStatus(Locale.Lookup("LOC_MTB_NO_LOCAL_PLAYER"), true);
    return;
  end

  local desired = BuildDesiredPins(m_selectedCityCount);
  local existingByCoord = {};
  local ownedPins = {};
  for _, pin in pairs(playerConfig:GetMapPins() or {}) do
    existingByCoord[CoordKey(pin:GetHexX(), pin:GetHexY())] = pin;
    if StartsWith(pin:GetName(), BLUEPRINT.ownedNamePrefix) then
      table.insert(ownedPins, pin);
    end
  end

  local deleted = 0;
  for _, pin in ipairs(ownedPins) do
    local key = CoordKey(pin:GetHexX(), pin:GetHexY());
    if desired[key] == nil then
      NotifyDmtRemoved(pin);
      playerConfig:DeleteMapPin(pin:GetID());
      existingByCoord[key] = nil;
      deleted = deleted + 1;
    end
  end

  local created = 0;
  local updated = 0;
  local conflicts = 0;
  local failed = 0;
  for key, target in pairs(desired) do
    local pin = existingByCoord[key];
    if pin ~= nil and not StartsWith(pin:GetName(), BLUEPRINT.ownedNamePrefix) then
      conflicts = conflicts + 1;
    else
      local isNew = pin == nil;
      if pin == nil then
        pin = playerConfig:GetMapPin(target.x, target.y);
      else
        NotifyDmtRemoved(pin);
      end

      if pin ~= nil then
        pin:SetName(target.name);
        pin:SetIconName(target.icon);
        pin:SetVisibility(localPlayer);
        NotifyDmtAdded(pin);
        if isNew then
          created = created + 1;
        else
          updated = updated + 1;
        end
      else
        failed = failed + 1;
      end
    end
  end

  Network.BroadcastPlayerInfo();
  UI.PlaySound("Map_Pin_Add");
  SetActionStatus(Locale.Lookup("LOC_MTB_IMPORT_RESULT", created, updated, deleted, conflicts, failed), conflicts > 0 or failed > 0);
end

local function RemoveOwnedPins()
  local localPlayer = Game.GetLocalPlayer();
  local playerConfig = PlayerConfigurations[localPlayer];
  if playerConfig == nil then
    SetActionStatus(Locale.Lookup("LOC_MTB_NO_LOCAL_PLAYER"), true);
    return;
  end

  local pinsToDelete = {};
  for _, pin in pairs(playerConfig:GetMapPins() or {}) do
    if StartsWith(pin:GetName(), BLUEPRINT.ownedNamePrefix) then
      table.insert(pinsToDelete, pin);
    end
  end

  for _, pin in ipairs(pinsToDelete) do
    NotifyDmtRemoved(pin);
    playerConfig:DeleteMapPin(pin:GetID());
  end

  Network.BroadcastPlayerInfo();
  if #pinsToDelete > 0 then
    UI.PlaySound("Map_Pin_Remove");
  end
  SetActionStatus(Locale.Lookup("LOC_MTB_REMOVE_RESULT", #pinsToDelete), false);
end

local function ConfirmRemove()
  local dialog = PopupDialog:new("MTB_RemoveBlueprintPins");
  dialog:AddTitle(Locale.Lookup("LOC_MTB_REMOVE_CONFIRM_TITLE"));
  dialog:AddText(Locale.Lookup("LOC_MTB_REMOVE_CONFIRM_TEXT"));
  dialog:AddButton(Locale.Lookup("LOC_YES"), RemoveOwnedPins);
  dialog:AddButton(Locale.Lookup("LOC_NO"), nil);
  dialog:Open();
end

local function UpdateSelection()
  local plan = GetPlan(m_selectedCityCount);
  Controls.Plan6Button:SetSelected(m_selectedCityCount == 6);
  Controls.Plan8Button:SetSelected(m_selectedCityCount == 8);
  Controls.Plan10Button:SetSelected(m_selectedCityCount == 10);
  if plan ~= nil then
    Controls.PlanSummary:SetText(Locale.Lookup("LOC_MTB_PLAN_SUMMARY", plan.cityCount, plan.cityCount * 3, plan.adjacency));
  end
end

local function SelectPlan(cityCount)
  m_selectedCityCount = cityCount;
  UpdateSelection();
  SetActionStatus(Locale.Lookup("LOC_MTB_READY"), false);
end

local function ClosePanel()
  Controls.ModalScrim:SetHide(true);
end

local function OpenPanel()
  local mapValid, mapMessage = ValidateCurrentMap();
  Controls.BlueprintTitle:SetText(Locale.Lookup(BLUEPRINT.titleKey));
  Controls.BlueprintDescription:SetText(Locale.Lookup(BLUEPRINT.descriptionKey));
  Controls.MapStatus:SetText(mapMessage);
  if mapValid then
    Controls.MapStatus:SetColor(UI.GetColorValue("COLOR_GREEN"));
  else
    Controls.MapStatus:SetColor(UI.GetColorValue("COLOR_RED"));
  end
  Controls.ImportButton:SetDisabled(not mapValid);
  UpdateSelection();
  SetActionStatus(Locale.Lookup("LOC_MTB_READY"), false);
  Controls.ModalScrim:SetHide(false);
end

local function TryInjectButton()
  if m_buttonInjected then
    return true;
  end

  -- MapPinListPanel's LuaContext has no ID. Its outer container belongs to
  -- MinimapPanel and is addressable, so place our button over the stock
  -- panel's deliberately empty 280x25 footer slot.
  local mapPinPanel = ContextPtr:LookUpControl("/InGame/MinimapPanel/MapPinListPanel");
  if mapPinPanel ~= nil then
    m_buttonInstance = {};
    ContextPtr:BuildInstanceForControl("BlueprintOverlayButtonInstance", m_buttonInstance, mapPinPanel);
    m_buttonInstance.BlueprintButton:RegisterCallback(Mouse.eLClick, OpenPanel);
    m_buttonInstance.BlueprintButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
    Controls.FallbackButton:SetHide(true);
    m_buttonInjected = true;
    print("MapTackBlueprints: attached to /InGame/MinimapPanel/MapPinListPanel");
    return true;
  end

  -- Retain a stack-based path for UI overhaul mods that expose the nested
  -- context under a named node.
  local mapPinStack = nil;
  local stackPaths = {
    "/InGame/MinimapPanel/MapPinListPanel/MapPinStack",
    "/InGame/MinimapPanel/MapPinListPanel/MapPinListPanel/MapPinStack",
    "/InGame/MapPinListPanel/MapPinStack",
  };
  for _, path in ipairs(stackPaths) do
    mapPinStack = ContextPtr:LookUpControl(path);
    if mapPinStack ~= nil then
      print("MapTackBlueprints: found MapPinStack at " .. path);
      break
    end
  end

  if mapPinStack == nil then
    local addButtonPaths = {
      "/InGame/MinimapPanel/MapPinListPanel/AddPinButton",
      "/InGame/MinimapPanel/MapPinListPanel/MapPinListPanel/AddPinButton",
      "/InGame/MapPinListPanel/AddPinButton",
    };
    for _, path in ipairs(addButtonPaths) do
      local addButton = ContextPtr:LookUpControl(path);
      if addButton ~= nil then
        mapPinStack = addButton:GetParent();
        print("MapTackBlueprints: found AddPinButton at " .. path);
        break
      end
    end
  end

  if mapPinStack == nil then
    return false;
  end

  m_buttonInstance = {};
  ContextPtr:BuildInstanceForControl("BlueprintButtonInstance", m_buttonInstance, mapPinStack);
  m_buttonInstance.BlueprintButton:RegisterCallback(Mouse.eLClick, OpenPanel);
  m_buttonInstance.BlueprintButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
  mapPinStack:CalculateSize();
  mapPinStack:ReprocessAnchoring();
  Controls.FallbackButton:SetHide(true);
  m_buttonInjected = true;
  return true;
end

local function OnLoadGameViewStateDone()
  if not TryInjectButton() then
    Controls.FallbackButton:SetHide(false);
    print("MapTackBlueprints: MapPinStack not found; showing fallback button");
  end
end

local function OnInputHandler(input)
  if not Controls.ModalScrim:IsHidden() and input:GetMessageType() == KeyEvents.KeyUp and input:GetKey() == Keys.VK_ESCAPE then
    ClosePanel();
    return true;
  end
  return false;
end

local function Initialize()
  ContextPtr:SetInputHandler(OnInputHandler, true);
  Controls.Plan6Button:RegisterCallback(Mouse.eLClick, function() SelectPlan(6); end);
  Controls.Plan8Button:RegisterCallback(Mouse.eLClick, function() SelectPlan(8); end);
  Controls.Plan10Button:RegisterCallback(Mouse.eLClick, function() SelectPlan(10); end);
  Controls.ImportButton:RegisterCallback(Mouse.eLClick, ImportSelectedPlan);
  Controls.RemoveButton:RegisterCallback(Mouse.eLClick, ConfirmRemove);
  Controls.CloseButton:RegisterCallback(Mouse.eLClick, ClosePanel);
  Controls.FallbackButton:RegisterCallback(Mouse.eLClick, OpenPanel);
  Controls.FallbackButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);

  Events.LoadGameViewStateDone.Add(OnLoadGameViewStateDone);
  TryInjectButton();
  print("MapTackBlueprints: initialized");
end

Initialize();
