object MVCDM: TMVCDM
  OldCreateOrder = False
  Height = 427
  Width = 491
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
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 64
    Top = 240
  end
  object FDStanStorageBinLink1: TFDStanStorageBinLink
    Left = 208
    Top = 228
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 208
    Top = 360
  end
  object FDStanStorageXMLLink1: TFDStanStorageXMLLink
    Left = 204
    Top = 300
  end
end
