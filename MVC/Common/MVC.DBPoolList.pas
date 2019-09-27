unit MVC.DBPoolList;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, MVC.LogUnit,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Generics.Collections,
  uDbConfig;

type
  TDbItem = class
  private
    FisStop: Integer;
    FAction: TDBConfig;
    FActionName: string;
    FUpDate: TDateTime;
    FisDead: integer;
    Fkey: string;
    procedure SetAction(const Value: TDBConfig);
    procedure SetisStop(const Value: Integer);
    procedure SetActionName(const Value: string);
    procedure SetUpDate(const Value: TDateTime);
    procedure SetisDead(const Value: integer);
  public
    property isStop: Integer read FisStop write SetisStop;
    property Db: TDBConfig read FAction write SetAction;
    property ActionName: string read FActionName write SetActionName;
    property UpDate: TDateTime read FUpDate write SetUpDate;
    property isDead: integer read FisDead write SetisDead;
  end;

type
  TDBPoolList = class
  private
    DBList: TDictionary<string, TDbItem>;
    function GetGUID: string;
  public
    function Add(Db: TDBConfig): TDbItem;
    function Get(): TDbItem;
    constructor Create();
    destructor Destroy; override;
    procedure ClearAction;
  end;

var
  _DBPoolList: TDBPoolList;

function getDbFromPool(): TDbItem;

function FreeDbToPool(DbItem: TDbItem): boolean;

implementation

{ TActionList }
function getDbFromPool(): TDbItem;
var
  item: TDbItem;
begin
  item := _DBPoolList.Get;
  if item = nil then
  begin
    item := _DBPoolList.Add(TDBConfig.Create);
  end;
  Result := item;
end;

function FreeDbToPool(DbItem: TDbItem): boolean;
begin
  DbItem.isStop := 1;
end;

function TDBPoolList.GetGUID: string;
var
  LTep: TGUID;
  sGUID: string;
begin
  CreateGUID(LTep);
  sGUID := GUIDToString(LTep);
  sGUID := StringReplace(sGUID, '-', '', [rfReplaceAll]);
  sGUID := Copy(sGUID, 2, Length(sGUID) - 2);
  result := sGUID;
end;

function TDBPoolList.Add(Db: TDBConfig): TDbItem;
var
  item: TDbItem;
  key: string;
begin
  MonitorEnter(DBList);
  try
    item := TDbItem.Create;
    item.Db := Db;
    item.isStop := 0;
    item.isDead := 0;
 //   item.ActionName := Action.ClassName;
    item.UpDate := Now + (1 / 24 / 60) * 1;
    key := GetGUID;
    try
      DBList.AddOrSetValue(key, item);
    except
     // log('session error2');
    end;
  finally
    MonitorExit(DBList);
    Result := item;
  end;
end;

procedure TDBPoolList.ClearAction;
var
  item: TDbItem;
  k, i: integer;
  ndate: TDateTime;
  key: string;
  tmp_dblist: TDictionary<string, TDbItem>;
begin
  MonitorEnter(DBList);
  try
    tmp_dblist := TDictionary<string, TDbItem>.Create(Dblist);

  finally
    MonitorExit(DBList);
  end;
  try
    for key in tmp_dblist.Keys do
    begin
      try
        DBList.TryGetValue(key, item);
        if item <> nil then
        begin
          if (Now() > item.UpDate) then
          begin
            if item.isDead = 0 then
            begin
              item.isDead := 1;
            end
            else
            begin

              item.Db.Free;
              item.Free;
              MonitorEnter(DBList);
              try
                DBList.Remove(key);
              finally
                MonitorExit(DBList);
              end;

             // Log('¶ÔÏó³ØÒÆ³ý:' + key);
            end;
          //  break;
            Sleep(100);
          end;
        end;
      except
      end;
    end;
  finally
    tmp_dblist.Clear;
    tmp_dblist.Free;
  end;
end;

constructor TDBPoolList.Create;
begin
  DBList := TDictionary<string, TDbItem>.Create;
end;

destructor TDBPoolList.Destroy;
var
  key: string;
  item: TDbItem;
begin

  for key in DBList.Keys do
  begin
    DBList.TryGetValue(key, item);
    if item <> nil then
    begin
      item.Db.Free;
      item.Free;
    end;
  end;
  DBList.Clear;
  DBList.Free;

  inherited;
end;

function TDBPoolList.Get(): TDbItem;
var
  key: string;
  item: TDbItem;
begin
  Result := nil;
  MonitorEnter(DBList);
  try
    for key in DBList.Keys do
    begin
      DBList.TryGetValue(key, item);
      if item <> nil then
      begin
        if (item.isDead = 0) and (item.isStop = 1) then
        begin
          item.isStop := 0;
          item.UpDate := Now + (1 / 24 / 60) * 1;
          Result := item;
          break;
        end;
      end;
    end;
  finally
    MonitorExit(DBList);
  end;
end;

{ TActionItem }

procedure TDbItem.SetAction(const Value: TDBConfig);
begin
  FAction := Value;
end;

procedure TDbItem.SetActionName(const Value: string);
begin
  FActionName := Value;
end;

procedure TDbItem.SetisDead(const Value: integer);
begin
  FisDead := Value;
end;

procedure TDbItem.SetisStop(const Value: Integer);
begin
  FisStop := Value;
end;

procedure TDbItem.SetUpDate(const Value: TDateTime);
begin
  FUpDate := Value;
end;

end.

