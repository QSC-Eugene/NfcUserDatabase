rapidjson = require("rapidjson")

local NumberofInterfaces = Properties["Number Of Interfaces"].Value
local NumberofPinOnlyUCIs = Properties["Number Of Pin Only UCIs"].Value

local DatabaseDir = "media/NfcTags.json"
local Database = rapidjson.decode('{"Tags": []"}')
local BaseTag = {
  ["UID"] = "",
  ["AccessLevel"] = 0, -- 0=User, 1=Admin, 2=SuperAdmin
  ["UserName"] = "",
  ["Created"] = "",
  ["PIN"] = 123456, -- 4-12 digits
  ["History"] = {
    ["Time"] = os.time(),
    ["Location"] = ""
  }
}
local ClearTime = 3 -- seconds

local PanelChoices = {"Off"}
local ModeChoices = {"Off", "Read", "Add", "Remove"}
local AccessLevelChoices = {"User", "Admin"}
Controls.LearningMode.Choices = ModeChoices
Controls.LearningMode.String = ModeChoices[1]
Controls.AccessLevel.Choices = AccessLevelChoices
Controls.AccessLevel.String = AccessLevelChoices[1]
Controls.LearningPanel.String = PanelChoices[1]

function GetSensors()
  local Choices = {}
  for _, comp in pairs(Component.GetComponents()) do
    if comp.Type == "touchscreen_sensors" then
      table.insert(Choices, comp.Name)
    end
  end
  for _, ctrl in ipairs(Controls.TSC_Sensor) do
    ctrl.Choices = Choices
  end
end
function GetStatus()
  local Choices = {}
  local UciChoices = {}
  for _, comp in pairs(Component.GetComponents()) do
    if comp.Type == "touch_screen_status" then
      table.insert(Choices, comp.Name)
      table.insert(UciChoices, comp.Name)
    elseif comp.Type == "uci_viewer" then
      table.insert(UciChoices, comp.Name)
    end
  end
  for _, ctrl in ipairs(Controls.TSC_Status) do
    ctrl.Choices = Choices
  end
  for _, ctrl in ipairs(Controls.Uci_Status) do
    ctrl.Choices = UciChoices
  end
end

function GetPanels()
  local TscChoices = {}
  local UciChoices = {}
  for _, device in pairs(Design.GetInventory()) do
    if device.Model:match("TSC%-%d+%-G3") then
      table.insert(TscChoices, device.Name)
    elseif device.Model:match("TSC") or device.Model:match("UCI") then
      table.insert(UciChoices, device.Name)
    end
  end
  for _, ctrl in ipairs(Controls.TSC_Name) do
    ctrl.Choices = TscChoices
  end
  for _, ctrl in ipairs(Controls.Uci_Name) do
    ctrl.Choices = UciChoices
  end
end

function SetupSensors()
  local LearningChoices = {"Off"}
  for i = 1, #Controls.TSC_Name do
    local name = Controls.TSC_Name[i].String
    local Sensor = Component.New(Controls.TSC_Sensor[i].String)
    local Status = Component.New(Controls.TSC_Status[i].String)
    if name ~= "" and Sensor["nfc.clear"] ~= nil and Status["current.uci"] ~= nil then
      print(
        "Setting up NFC for " ..
          name .. " with " .. Controls.TSC_Sensor[i].String .. " and " .. Controls.TSC_Status[i].String
      )
      table.insert(LearningChoices, name)
      Sensor["nfc.clear"]:Trigger()
      Sensor["nfc.uid"].EventHandler = function(ctrl)
        if ctrl.String ~= "" then
          local UID = ctrl.String
          print(name .. ": " .. UID)
          if name == Controls.LearningPanel.String then
            ProcessTag(UID)
          else
            accessLevel, username = CheckTag(UID, name)
            Login(accessLevel, username, Status["current.uci"].String)
          end
          Sensor["nfc.clear"]:Trigger()
        end
      end
    end
  end
  Controls.LearningPanel.Choices = LearningChoices
end
function SetupPinAccess()
  for i = 1, NumberofInterfaces do
    local name = Controls.TSC_Name[i].String
    local Status = Component.New(Controls.TSC_Status[i].String)
    if name ~= "" and Status["current.uci"] ~= nil then
      print("Setting up PinAccess for " .. name .. " with " .. Controls.TSC_Status[i].String)
      Controls.PinEntry[i].EventHandler = function(ctrl)
        if ctrl.String ~= "" then
          local accessLevel, username = PinCheck(ctrl.String, name)
          Login(accessLevel, username, Status["current.uci"].String)
          ctrl.String = ""
        end
      end
    else
      Controls.PinEntry[i].EventHandler = nil
    end
  end
  for i = 1, NumberofPinOnlyUCIs do
    local name = Controls.Uci_Name[i].String
    local Status = Component.New(Controls.Uci_Status[i].String)
    if name ~= "" and Status["current.uci"] ~= nil then
      print("Setting up PinAccess for " .. name .. " with " .. Controls.Uci_Status[i].String)
      Controls.PinEntry[i + NumberofInterfaces].EventHandler = function(ctrl)
        if ctrl.String ~= "" then
          local accessLevel, username = PinCheck(ctrl.String, name)
          Login(accessLevel, username, Status["current.uci"].String)
          ctrl.String = ""
        end
      end
    else
      Controls.PinEntry[i + NumberofInterfaces].EventHandler = nil
    end
  end
end

function LoadDatabase()
  if not System.IsEmulating then
    print("Checking for Tag Database")
    if
      pcall(
        function()
          Database = rapidjson.load(DatabaseDir)
        end
      )
     then
      -- print(rapidjson.encode(Database))
      print(#Database.Tags .. " Tags in Database")
    else
      print("Error loading database")
      Database = {}
    end
  end
end
function ProcessTag(UID)
  local mode = Controls.LearningMode.String

  if mode == "Read" then
    local _, _, tag = CheckTag(UID)
    if tag then
      Controls.UserName.String = tag.UserName
      Controls.AccessLevel.String = (tag.AccessLevel == 0 and "User" or "Admin")
      Controls.UID.String = tag.UID
      Controls.BackupPin.String = tag.PIN or ""
      Controls.Created.String = os.date("%e %b %Y %H:%M:%S%p", tag.Created)
      local history = ""
      for _, log in ipairs(tag.History) do
        history = history .. log.Location .. ": " .. os.date("%e %b %Y %H:%M:%S%p", log.Time) .. "\n"
      end
      Controls.History.String = history
    end
  elseif mode == "Add" then
    AddTag(
      UID,
      (Controls.AccessLevel.String == "Admin" and 1 or 0),
      Controls.UserName.String,
      tonumber(Controls.BackupPin.String)
    )
    ResetControls()
    Controls.LearningMode.String = "Off"
  elseif mode == "Remove" then
    RemoveTag(UID)
    ResetControls()
    Controls.LearningMode.String = "Off"
  end
end

function AddTag(UID, accessLevel, userName, backupPin)
  if UID then
    local accessLevel = accessLevel or 0
    local userName = userName or "TAG:" .. UID
    local created = os.time()
    local backupPin = backupPin or ""
    table.insert(
      Database.Tags,
      {
        ["UID"] = UID,
        ["AccessLevel"] = accessLevel, -- 0=User, 1=Admin, 2=SuperAdmin
        ["UserName"] = userName,
        ["Created"] = created,
        ["PIN"] = backupPin,
        ["History"] = {}
      }
    )
    rapidjson.dump(Database, DatabaseDir)
    RefreshList()
  else
    print("Error, Cant add tag without UID")
  end
end

function RemoveTag(UID)
  for i, tag in ipairs(Database.Tags) do
    if tag.UID == UID then
      table.remove(Database.Tags, i)
      rapidjson.dump(Database, DatabaseDir)
      RefreshList()
      return true
    end
  end
  return false
end
function CheckTag(UID, location)
  for i, tag in ipairs(Database.Tags) do
    if tag.UID == tostring(UID) then
      if location then -- add history when used
        table.insert(tag.History, 1, {["Time"] = os.time(), ["Location"] = location})
        while (#tag.History > Controls.HistoryLength.Value) do
          table.remove(tag.History)
        end
        rapidjson.dump(Database, DatabaseDir)
      end
      return tag.AccessLevel, tag.UserName, tag
    end
  end
  return -1, "Unknown Tag"
end
function PinCheck(pin, location)
  for _, tag in ipairs(Database.Tags) do
    if tonumber(tag.PIN) == tonumber(pin) then
      if location then -- add history when used
        table.insert(tag.History, 1, {["Time"] = os.time(), ["Location"] = location})
        while (#tag.History > Controls.HistoryLength.Value) do
          table.remove(tag.History)
        end
        rapidjson.dump(Database, DatabaseDir)
      end
      return tag.AccessLevel, tag.UserName
    end
  end
  return -1, "Unknown Pin"
end

function Login(accessLevel, name, uci)
  print("Login", accessLevel, name, uci)
  local name = name or ""
  if uci ~= nil then
    if accessLevel >= 0 then --valid user
      Uci.SetVariable(uci, "IsAdmin", accessLevel >= 1)
      Uci.SetVariable(uci, "Locked", false)
      Uci.SetVariable(uci, "UserName", '"' .. name .. '"')
    else
      print("Invalid Login:", name)
    end
  end
end

function ClearList()
  for i = 1, NumberOfLines do
    Controls["ListName"][i].String = ""
    Controls["ListUID"][i].String = ""
    Controls["ListCreated"][i].String = ""
    Controls["ListAccessLevel"][i].String = ""
  end
end

function RefreshList()
  ClearList()
  if Database.Tags and #Database.Tags <= NumberOfLines then
    Controls.ListScroll.IsInvisible = true
    for i, user in ipairs(Database.Tags) do
      print(user.UserName, user.UID, os.date("%e %b %Y %H:%M:%S%p", user.Created))
      Controls["ListName"][i].String = user.UserName
      Controls["ListUID"][i].String = user.UID
      Controls["ListCreated"][i].String = os.date("%e %b %Y %H:%M:%S%p", user.Created)
      Controls["ListAccessLevel"][i].String = AccessLevelChoices[user.AccessLevel + 1]
    end
  else
    Controls.ListScroll.IsInvisible = false
    local scroll = 100 - Controls.ListScroll.Value
    local clicks = #Database.Tags - NumberOfLines + 1
    local scrollSize = 100 / clicks
    local start = scroll ~= 100 and math.floor(scroll / scrollSize) or clicks - 1
    print("Scroll", scroll, clicks, scrollSize, start)
    for i = 1, NumberOfLines do
      local user = Database.Tags[start + i]
      Controls["ListName"][i].String = user.UserName
      Controls["ListUID"][i].String = user.UID
      Controls["ListCreated"][i].String = os.date("%e %b %Y %H:%M:%S%p", user.Created)
      Controls["ListAccessLevel"][i].String = AccessLevelChoices[user.AccessLevel + 1]
    end
  end
end

function ResetControls()
  -- Controls.Created.IsInvisible = Controls.LearningMode.String ~= "Read"
  -- Controls.History.IsInvisible = Controls.LearningMode.String ~= "Read"
  Controls.UserName.String = ""
  Controls.UID.String = ""
  Controls.BackupPin.String = ""
  Controls.Created.String = ""
  Controls.History.String = ""
  Controls.ListScroll.Value = 100
  for i = 1, NumberOfLines do
    Controls["ListName"][i].String = ""
    Controls["ListUID"][i].String = ""
    Controls["ListCreated"][i].String = ""
    Controls["ListAccessLevel"][i].String = ""
  end
end
function Initialize()
  Controls.EnableListDelete.Boolean = false
  GetPanels()
  GetSensors()
  GetStatus()

  EnableListDelete()
  ResetControls()
  LoadDatabase()
  RefreshList()
  SetupSensors()
  SetupPinAccess()
end

function VerifyUniquePin(pin)
  if tostring(pin):len() < 4 or tostring(pin):len() > 12 then
    return false
  end
  for _, tag in ipairs(Database.Tags) do
    if tag.PIN == pin then
      return false
    end
  end
  return true
end

function EnableListDelete()
  for i = 1, NumberOfLines do
    Controls["ListDelete"][i].IsDisabled = not Controls.EnableListDelete.Boolean
  end
end
Controls.EnableListDelete.EventHandler = EnableListDelete

for i, ctrl in ipairs(Controls.ListDelete) do
  ctrl.EventHandler = function()
    local UID = Controls["ListUID"][i].String
    local name = Controls["ListName"][i].String
    if RemoveTag(UID) then
      print("Removed " .. name)
    end
  end
end

for _, ctrl in ipairs(Controls.TSC_Name) do
  ctrl.EventHandler = function()
    SetupSensors()
    SetupPinAccess()
  end
end
for _, ctrl in ipairs(Controls.TSC_Sensor) do
  ctrl.EventHandler = SetupSensors
end
for _, ctrl in ipairs(Controls.TSC_Status) do
  ctrl.EventHandler = function()
    SetupSensors()
    SetupPinAccess()
  end
end
for _, ctrl in ipairs(Controls.Uci_Name) do
  ctrl.EventHandler = function()
    SetupPinAccess()
  end
end
for _, ctrl in ipairs(Controls.Uci_Status) do
  ctrl.EventHandler = function()
    SetupPinAccess()
  end
end
Controls.RefreshList.EventHandler = RefreshList
Controls.ListScroll.EventHandler = RefreshList
Controls.BackupPin.EventHandler = function()
  if Controls.LearningMode.String == "Add" then
    Controls.UniquePin.Boolean = VerifyUniquePin(Controls.BackupPin.String)
  else
    Controls.UniquePin.Boolean = false
  end
end

Initialize()
