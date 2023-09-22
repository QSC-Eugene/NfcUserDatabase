-- layout["code"] = {PrettyName = "Code",Style = "None"}

local DefaultControlHeight = 24

local CurrentPageIndex = props["page_index"].Value
local NumerOfInterfaces = props["Number Of Interfaces"].Value
local NumerOfPinOnlyUCIs = props["Number Of Pin Only UCIs"].Value

if CurrentPageIndex == 1 then --List
  layout["RefreshList"] = {
    Style = "Button",
    ButtonStyle = "Trigger",
    Size = {50,50},
    Position = {550, 30}, 
    PrettyName = "List~Refresh"
  }
  layout["EnableListDelete"] = {
    Style = "Button",
    ButtonStyle = "Toggle",
    Legend = "Enable\rDelete",
    Size = {50,50},
    Position = {550, 90},
    PrettyName = "List~Enable Delete"
  }
  layout["ListScroll"] = {
    Style = "Fader",
    Position = {10,10 + DefaultControlHeight},
    Size = {20, (NumberOfLines * DefaultControlHeight)},
  }
  table.insert(
    graphics,
    {
      Type = "Header",
      Text = "User Name",
      Position = {40, 10},
      Size = {100, DefaultControlHeight},
    }
  )
  table.insert(
    graphics,
    {
      Type = "Header",
      Text = "Tag UID",
      Position = {140, 10},
      Size = {100, DefaultControlHeight},
    }
  )
  table.insert(
    graphics,
    {
      Type = "Header",
      Text = "Created",
      Position = {240, 10},
      Size = {150, DefaultControlHeight},
    }
  )
  table.insert(
    graphics,
    {
      Type = "Header",
      Text = "Access Level",
      Position = {390, 10},
      Size = {75, DefaultControlHeight},
    }
  )
  for i = 1, NumberOfLines do
    layout["ListName "..i] = {
      Style = "Text",
      Size = {100, DefaultControlHeight},
      Position = {40, 10 + (i) * DefaultControlHeight}, 
      HTextAlign = "Right",
      Padding = 5
    }
    layout["ListUID "..i] = {
      Style = "Text",
      Size = {100, DefaultControlHeight},
      Position = {140, 10 + (i) * DefaultControlHeight}, 
      HTextAlign = "Right",
      Padding = 5
    }
    layout["ListCreated "..i] = {
      Style = "Text",
      Size = {150, DefaultControlHeight},
      Position = {240, 10 + (i) * DefaultControlHeight}, 
      HTextAlign = "Right",
      Padding = 5
    }
    layout["ListAccessLevel "..i] = {
      Style = "Text",
      Size = {75, DefaultControlHeight},
      Position = {390, 10 + (i) * DefaultControlHeight}, 
      HTextAlign = "Right",
      Padding = 5
    }
    layout["ListDelete "..i] = {
      Style = "Button",
      ButtonStyle = "Trigger",
      Size = {DefaultControlHeight, DefaultControlHeight},
      Position = {470, 10 + (i) * DefaultControlHeight}, 
      margin = 0,
      Padding = 0,
    }
    layout["ListEdit "..i] = {
      Style = "Button",
      ButtonStyle = "Trigger",
      Size = {DefaultControlHeight, DefaultControlHeight},
      Position = {500, 10 + (i) * DefaultControlHeight}, 
      margin = 0,
      Padding = 0,
    }
  end

elseif CurrentPageIndex == 2 then --UserEdit
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "User Name",
      Position = {10, 10},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["UserEditName"] = {
    Style = "Text",
    Size = {100, DefaultControlHeight},
    Position = {110, 10}, 
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "UID",
      Position = {10, 40},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["UserEditUID"] = {
    Style = "Text",
    Size = {100, DefaultControlHeight},
    Position = {110, 40}, 
  }
  layout["UserEditUidGen"] = {
    Style = "Button",
    ButtonStyle = "Trigger",
    Size = {DefaultControlHeight,DefaultControlHeight},
    Position = {220, 40}, 
    PrettyName = "UserEdit~UID Gen",
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "Access Level",
      Position = {10, 70},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["UserEditAccessLevel"] = {
    Style = "ComboBox",
    Size = {100, DefaultControlHeight},
    Position = {110, 70}, 
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "Pin",
      Position = {10, 100},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["UserEditPin"] = {
    Style = "Text",
    Size = {100, DefaultControlHeight},
    Position = {110, 100}, 
  }
  layout["UserEditUniquePin"] = {
    Style = "Led",
    Size = {DefaultControlHeight, DefaultControlHeight},
    Position = {220, 100},
    Color = {0,0,255}
  }
  layout["UserEditSave"] = {
    Style = "Button",
    ButtonStyle = "Trigger",
    Size = {50, 50},
    Position = {270, 10}, 
  }
  layout["UserEditClear"] = {
    Style = "Button",
    ButtonStyle = "Trigger",
    Size = {50, 50},
    Position = {270, 70}, 
  }
elseif CurrentPageIndex == 3 then --TagLearning
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "Learing Panel",
      Position = {10, 10},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["LearningPanel"] = {
    Style = "ComboBox",
    Size = {100, DefaultControlHeight},
    Position = {110, 10}, 
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "Learning Mode",
      Position = {10, 40},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["LearningMode"] = {
    Style = "ComboBox",
    Size = {100, DefaultControlHeight},
    Position = {110, 40}, 
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "Access Level",
      Position = {10, 70},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["AccessLevel"] = {
    Style = "ComboBox",
    Size = {100, DefaultControlHeight},
    Position = {110, 70}, 
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "User Name",
      Position = {10, 100},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["UserName"] = {
    Style = "Text",
    Size = {100, DefaultControlHeight},
    Position = {110, 100}, 
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "UID",
      Position = {10, 130},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["UID"] = {
    Style = "Text",
    Size = {100, DefaultControlHeight},
    Position = {110, 130}, 
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "Backup Pin",
      Position = {10, 160},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["BackupPin"] = {
    Style = "Text",
    Size = {100, DefaultControlHeight},
    Position = {110, 160}, 
  }
  layout["UniquePin"] = {
    Style = "Led",
    Size = {DefaultControlHeight, DefaultControlHeight},
    Position = {220, 160},
    Color = {0,0,255}
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "Created",
      Position = {10, 190},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["Created"] = {
    Style = "Text",
    Size = {200, DefaultControlHeight},
    Position = {110, 190}, 
  }
  table.insert(
    graphics,
    {
      Type = "Label",
      Text = "History",
      Position = {10, 220},
      Size = {100, DefaultControlHeight},
    }
  )
  layout["History"] = {
    Style = "Text",
    Size = {200, DefaultControlHeight*10},
    Position = {110, 220}, 
  }


elseif CurrentPageIndex == 4 then --Interfaces
  table.insert(
    graphics,
    {
      Type = "Header",
      Text = "TSC Name",
      Position = {10, 10},
      Size = {100, DefaultControlHeight},
    }
  )
  table.insert(
    graphics,
    {
      Type = "Header",
      Text = "Sernsor",
      Position = {110, 10},
      Size = {200, DefaultControlHeight},
    }
  )
  table.insert(
    graphics,
    {
      Type = "Header",
      Text = "Status",
      Position = {310, 10},
      Size = {200, DefaultControlHeight},
    }
  )
  for i = 1, NumerOfInterfaces do
    layout["TSC_Name "..i] = {
      Style = "ComboBox",
      Size = {100, DefaultControlHeight},
      Position = {10, 10 + (i) * DefaultControlHeight}, 
      PrettyName = "Tsc"..i.."~Name",
    }
    layout["TSC_Sensor "..i] = {
      Style = "ComboBox",
      Size = {200, DefaultControlHeight},
      Position = {110, 10 + (i) * DefaultControlHeight}, 
      PrettyName = "Tsc"..i.."~Sensor",
    }
    layout["TSC_Status "..i] = {
      Style = "ComboBox",
      Size = {200, DefaultControlHeight},
      Position = {310, 10 + (i) * DefaultControlHeight}, 
      PrettyName = "Tsc"..i.."~StatusComponent",
    }
  end
  for i = 1, NumerOfPinOnlyUCIs do
    layout["Uci_Name "..i] = {
      Style = "ComboBox",
      Size = {100, DefaultControlHeight},
      Position = {10, 10 + (i + NumerOfInterfaces) * DefaultControlHeight}, 
      PrettyName = "Uci"..i.."~Name",
    }
    layout["Uci_Status "..i] = {
      Style = "ComboBox",
      Size = {200, DefaultControlHeight},
      Position = {310, 10 + (i + NumerOfInterfaces) * DefaultControlHeight}, 
      PrettyName = "Uci"..i.."~StatusComponent",
    }
  end

end

for i = 1, NumerOfInterfaces do
  layout["PinEntry "..i] = {
    Style = "None",
    PrettyName = "Tsc"..i.."~PinEntry",
  }
end
for i = 1, NumerOfPinOnlyUCIs do
  layout["PinEntry "..(i + NumerOfInterfaces)] = {
    Style = "None",
    PrettyName = "Uci"..i.."~PinEntry",
  }
end
layout["HistoryLength"] = {
  Style = "None",
  PrettyName = "History Length",
}
