rapidjson = require("rapidjson")

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
local ClearTime = 3

-- local TouchScreens = {
--   {
--     ["TSC_Name"] = "TscG310-Reception", ["Sensor"] = Component.New("Sensors_TscG310-Reception"), ["UCI"] = "Reception"
--   },
--   {
--     ["TSC_Name"] = "TSCG35-1", ["Sensor"] = Component.New("Sensors_TscG35-1"), ["UCI"] = "BallroomA"
--   },
--   {
--     ["TSC_Name"] = "TSCG35-2", ["Sensor"] = Component.New("Sensors_TscG35-2"), ["UCI"] = "BallroomB"
--   },
-- }

local PanelChoices = {"Off"}
local ModeChoices = {"Off", "Read", "Add", "Remove"}
local AccessLevelChoices = {"User", "Admin"}
local Sensors = {}
local StatusBlocks = {}
Controls.LearningMode.Choices = ModeChoices
Controls.LearningMode.String = ModeChoices[1]
Controls.AccessLevel.Choices = AccessLevelChoices
Controls.AccessLevel.String = AccessLevelChoices[1]
Controls.LearningPanel.String = PanelChoices[1]

function GetSensors()
  Sensors = {}
  local Choices = {}
  for _, comp in pairs(Component.GetComponents()) do
    if comp.Type == "touchscreen_sensors" then
      Sensors[comp.Name] = comp
      table.insert(Choices, comp.Name)
    end
  end
  for _, ctrl in ipairs(Controls.TSC_Sensor) do
    ctrl.Choices = Choices
  end
end
function GetStatus()
  StatusBlocks = {}
  local Choices = {}
  for _, comp in pairs(Component.GetComponents()) do
    if comp.Type == "touch_screen_status" then
      StatusBlocks[comp.Name] = comp
      table.insert(Choices, comp.Name)
    end
  end
  for _, ctrl in ipairs(Controls.TSC_Status) do
    ctrl.Choices = Choices
  end
end
function GetTscPanels()
  local Choices = {}
  for _, device in pairs(Design.GetInventory()) do
    if device.Model:match("TSC%-%d+%-G3") then
      table.insert(Choices, device.Name)
    end
  end
  for _, ctrl in ipairs(Controls.TSC_Name) do
    ctrl.Choices = Choices
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
        "Setting up " .. name .. " with " .. Controls.TSC_Sensor[i].String .. " and " .. Controls.TSC_Status[i].String
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
            accessLevel, username = CheckTag(UID,name)
            Login(accessLevel,username,Status["current.uci"].String)
          end 
          Sensor["nfc.clear"]:Trigger()
        end
      end
    end
  end
  Controls.LearningPanel.Choices = LearningChoices
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

function Login(accessLevel,name,uci)
  print("Login",accessLevel,name,uci)
  local name = name or ""
  if uci ~= nil then 
    if accessLevel >= 0 then --valid user
      Uci.SetVariable(uci,"Admin",accessLevel >= 1)
      Uci.SetVariable(uci,"Locked",false)
      Uci.SetVariable(uci,"UserName",'"'..name..'"')
    else 
      print("Invalid Login:",name)
    end 
  end 
end 

function RefreshList()
  if Database.Tags and #Database.Tags <= NumberOfLines then
    Controls.ListScroll.IsInvisible = true
    for i,user in ipairs(Database.Tags) do
      print(user.UserName,user.UID,os.date("%e %b %Y %H:%M:%S%p", user.Created))
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
    print("Scroll", scroll, clicks, scrollSize,start)
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
end
function Initialize()
  GetTscPanels()
  GetSensors()
  GetStatus()

  ResetControls()
  LoadDatabase()
  RefreshList()
  SetupSensors()
end

for _, ctrl in ipairs(Controls.TSC_Name) do
  ctrl.EventHandler = SetupSensors
end
for _, ctrl in ipairs(Controls.TSC_Sensor) do
  ctrl.EventHandler = SetupSensors
end
for _, ctrl in ipairs(Controls.TSC_Status) do
  ctrl.EventHandler = SetupSensors
end
Controls.RefreshList.EventHandler = RefreshList
Controls.ListScroll.EventHandler = RefreshList

Initialize()
