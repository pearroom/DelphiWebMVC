object DM: TDM
  OldCreateOrder = False
  Height = 304
  Width = 329
  object FDGUIxWait: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrNone
    Left = 223
    Top = 152
  end
  object MySQLDriver: TFDPhysMySQLDriverLink
    Left = 75
    Top = 38
  end
  object DBManager: TFDManager
    DriverDefFileName = 'MYSQL'
    WaitCursor = gcrNone
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 220
    Top = 88
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 72
    Top = 88
  end
  object FDPhysOracleDriverLink1: TFDPhysOracleDriverLink
    Left = 72
    Top = 144
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 72
    Top = 192
  end
end
