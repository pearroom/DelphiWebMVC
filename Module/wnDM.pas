unit wnDM;

interface

uses
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Phys.MySQLDef,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.MySQL, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.UI, System.Classes, FireDAC.Comp.DataSet,
  System.SysUtils, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.Phys.OracleDef, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, FireDAC.Phys.Oracle,
  FireDAC.Phys.MSAccDef, FireDAC.Phys.MSAcc;

type
  TDM = class(TDataModule)
    FDGUIxWait: TFDGUIxWaitCursor;
    MySQLDriver: TFDPhysMySQLDriverLink;
    DBManager: TFDManager;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  DM: TDM;

implementation


{$R *.dfm}

end.

