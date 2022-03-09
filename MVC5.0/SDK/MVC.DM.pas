{ ******************************************************* }
{ }
{ DelphiWebMVC 5.0 }
{ E-Mail:pearroom@yeah.net }
{ 版权所有 (C) 2022-2 苏兴迎(PRSoft) }
{ }
{ ******************************************************* }
unit MVC.DM;
{$I mvc.inc}

interface

uses
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Phys.MySQLDef, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.MySQL, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.UI, System.Classes, FireDAC.Comp.DataSet,
  System.SysUtils, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.Phys.OracleDef, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, FireDAC.Phys.Oracle,
  FireDAC.Phys.FBDef,
//  {$IFDEF VER340}FireDAC.Phys.SQLiteWrapper.Stat, {$ENDIF}
//  {$IFDEF CONSOLE} FireDAC.ConsoleUI.Wait, {$ENDIF}
//  {$IFDEF SERVICE} FireDAC.ConsoleUI.Wait, {$ENDIF}
//  {$IFDEF MSWINDOWS} FireDAC.VCLUI.Wait, {$ENDIF}
  FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Stan.StorageJSON,
  FireDAC.Stan.StorageBin, FireDAC.Stan.StorageXML;

type
  TMVCDM = class
    MySQLDriver: TFDPhysMySQLDriverLink;
    DBManager: TFDManager;
    SQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    OracleDriverLink1: TFDPhysOracleDriverLink;
    MSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FBDriverLink1: TFDPhysFBDriverLink;
    BinLink1: TFDStanStorageBinLink;
    JSONLink1: TFDStanStorageJSONLink;
    XMLLink1: TFDStanStorageXMLLink;

  public
    constructor Create();
    destructor Destroy; override;

  end;

var
  MVCDM: TMVCDM;


implementation
{ TMVCDM }

constructor TMVCDM.Create();
begin
  DBManager := TFDManager.Create(nil);
  MySQLDriver := TFDPhysMySQLDriverLink.Create(nil);
  SQLiteDriverLink1 := TFDPhysSQLiteDriverLink.Create(nil);
  OracleDriverLink1 := TFDPhysOracleDriverLink.Create(nil);
  MSSQLDriverLink1 := TFDPhysMSSQLDriverLink.Create(nil);
  FBDriverLink1 := TFDPhysFBDriverLink.Create(nil);
  BinLink1 := TFDStanStorageBinLink.Create(nil);
  JSONLink1 := TFDStanStorageJSONLink.Create(nil);
  XMLLink1 := TFDStanStorageXMLLink.Create(nil);

end;

destructor TMVCDM.Destroy;
begin
  DBManager.free;
  MySQLDriver.free;
  SQLiteDriverLink1.free;
  OracleDriverLink1.free;
  MSSQLDriverLink1.free;
  FBDriverLink1.free;
  BinLink1.free;
  JSONLink1.free;
  XMLLink1.free;
  inherited;
end;

initialization
  MVCDM := TMVCDM.Create();


finalization
  MVCDM.free;

end.

