-- table.insert(ctrls,{Name = "code",ControlType = "Text",PinStyle = "Input",Count = 1})

local NumerOfInterfaces = props["Number Of Interfaces"].Value

table.insert(
  ctrls,
  {
    Name = "LearningPanel",
    ControlType = "Text",
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "LearningMode",
    ControlType = "Text",
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "AccessLevel",
    ControlType = "Text",
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "UserName",
    ControlType = "Text",
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "UID",
    ControlType = "Text",
    PinStyle = "None",
    UserPin = false,
  }
)

table.insert(
  ctrls,
  {
    Name = "BackupPin",
    ControlType = "Text",
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "Created",
    ControlType = "Indicator",
    IndicatorType = "Text",
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "History",
    ControlType = "Indicator",
    IndicatorType = "Text",
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = HistoryLength,
    ControlType = "Knob",
    ControlUnit = "Integer",
    Min = 3,
    Max = 100,
    DefaultValue = 10,
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "RefreshList",
    ControlType = "Button",
    ButtonType = "Trigger",
    PinStyle = "Input", 
    UserPin = true,
    Icon = "Refresh",
    IconType = "Icon"
  }
)
table.insert(
  ctrls,
  {
    Name = "EnableListDelete",
    ControlType = "Button",
    ButtonType = "Toggle",
    PinStyle = "Both",
    UserPin = true,
    DefaultValue = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "ListDelete",
    ControlType = "Button",
    ButtonType = "Trigger",
    PinStyle = "None",
    UserPin = false,
    Count = NumberOfLines,
    Icon = "X Circle",
    IconType = "Icon"
  }
)
table.insert(
  ctrls,
  {
    Name = "ListScroll",
    ControlType = "Knob",
    ControlUnit = "Percent",
    Min = 0,
    Max = 100,
    DefaultValue = 100,
    PinStyle = "None",
    UserPin = false,
  }
)
table.insert(
  ctrls,
  {
    Name = "ListName",
    ControlType = "Indicator",
    IndicatorType = "Text",
    PinStyle = "None",
    UserPin = false,
    Count = NumberOfLines,
  }
)
table.insert(
  ctrls,
  {
    Name = "ListUID",
    ControlType = "Indicator",
    IndicatorType = "Text",
    PinStyle = "None",
    UserPin = false,
    Count = NumberOfLines,
  }
)
table.insert(
  ctrls,
  {
    Name = "ListAccessLevel",
    ControlType = "Indicator",
    IndicatorType = "Text",
    PinStyle = "None",
    UserPin = false,
    Count = NumberOfLines,
  }
)
table.insert(
  ctrls,
  {
    Name = "ListCreated",
    ControlType = "Indicator",
    IndicatorType = "Text",
    PinStyle = "None",
    UserPin = false,
    Count = NumberOfLines,
  }
)
table.insert(
  ctrls,
  {
    Name = "ListSelect",
    ControlType = "Button",
    ButtonType = "Trigger",
    PinStyle = "None",
    UserPin = false,
    Count = NumberOfLines,
  }
)
table.insert(
  ctrls,
  {
    Name = "TSC_Name",
    ControlType = "Text",
    PinStyle = "Both",
    UserPin = true,
    Count = NumerOfInterfaces > 1 and NumerOfInterfaces or 2,
  }
)
table.insert(
  ctrls,
  {
    Name = "TSC_Sensor",
    ControlType = "Text",
    PinStyle = "Both",
    UserPin = true,
    Count = NumerOfInterfaces > 1 and NumerOfInterfaces or 2,
  }
)
table.insert(
  ctrls,
  {
    Name = "TSC_Status",
    ControlType = "Text",
    PinStyle = "Both",
    UserPin = true,
    Count = NumerOfInterfaces > 1 and NumerOfInterfaces or 2,
  }
)
