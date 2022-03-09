unit MVC.DBPool;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Generics.Collections;

type
  TDBPool = class
  private
    DbList: Tlist<TFDConnection>;
  public
    function GetDb(DbType: string): TFDConnection;
    function FreeDb(Db: TFDConnection): boolean;
    procedure AddDb(size: Integer; DbType: string);
    constructor Create();
    destructor Destroy; override;
  end;

var
  _DbPool: TDBPool;

implementation

{ TDBPool }

procedure TDBPool.AddDb(size: Integer; DbType: string);
var
  i: Integer;
  Db: TFDConnection;
begin
  for i := 0 to size - 1 do
  begin
    Db := TFDConnection.Create(nil);
  //  Db.FetchOptions.Mode:=fmAll;
  //  Db.FetchOptions.RecordCountMode:= TFDRecordCountMode.cmTotal;
    Db.ConnectionDefName := DbType;
    DbList.Add(Db);
  end;
end;

constructor TDBPool.Create();
begin
  DbList := TList<TFDConnection>.Create();
end;

destructor TDBPool.Destroy;
var
  i: Integer;
begin
  for i := 0 to DbList.Count - 1 do
  begin
    DbList[i].Free;
  end;
  DbList.Clear;
  DbList.Free;
  inherited;
end;

function TDBPool.FreeDb(Db: TFDConnection): boolean;
begin
  Db.Connected := false;
end;

function TDBPool.GetDb(DbType: string): TFDConnection;
var
  i: Integer;
  Db:TFDConnection;
begin

//  try
//    Db:=TFDConnection.Create(nil);
//    Db.ConnectionDefName := DbType;
//    Result:=Db;
//  except
//    Result := nil;
//  end;
  try
    for i := 0 to DbList.Count - 1 do
    begin
      if DbList[i].ConnectionDefName = DbType then
      begin

        Result := DbList[i].CloneConnection as TFDConnection;
        break;
      end;
    end;
  finally

  end;

end;

end.

