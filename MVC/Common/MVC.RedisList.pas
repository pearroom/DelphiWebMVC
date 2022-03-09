{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       鐗堟潈鎵�鏈?(C) 2019 鑻忓叴杩?PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.RedisList;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, MVC.RedisM;

type
  TRedisItem = class
  private
    FisLock: Boolean;
    Fguid: string;
    Ftimerout: TDateTime;
    Fisdel: Boolean;
    procedure SetisLock(const Value: Boolean);
    procedure Setguid(const Value: string);
    procedure Settimerout(const Value: TDateTime);
    procedure Setisdel(const Value: Boolean);

  public
    item: TRedisM;
    property isdel: Boolean read Fisdel write Setisdel;
    property timerout: TDateTime read Ftimerout write Settimerout;
    property guid: string read Fguid write Setguid;
    property isLock: Boolean read FisLock write SetisLock;
    constructor Create();
    destructor Destroy; override;
  end;

type
  TRedisList = class(TThread)
  private
    initSize: integer;
    list: Tlist<TRedisItem>;
    function GetGUID: string;
    function additem(): TRedisItem;
  protected
    procedure Execute; override;
  public
    isclose: Boolean;
    procedure RunClear();
    function OpenRedis(): TRedisItem;
    function CloseRedis(guid: string): boolean;
    constructor Create(size: integer);
    destructor Destroy; override;
  end;

implementation

uses
  MVC.LogUnit;

{ TRedisList }
function TRedisList.GetGUID: string;
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

function TRedisList.additem: TRedisItem;
var
  item: TRedisItem;
begin
  item := TRedisItem.Create();
  item.isLock := false;
  item.isdel := false;
  item.guid := GetGUID;
  item.timerout := Now + (1 / 24 / 60) * 30; //24小时过期
  list.Add(item);
  Result := item;
end;

function TRedisList.CloseRedis(guid: string): boolean;
var
  i: Integer;
begin
  Result := true;
  for i := 0 to list.Count - 1 do
  begin
    if list[i].guid = guid then
    begin
      list[i].isLock := false;
      break;
    end;
  end;
end;

constructor TRedisList.Create(size: integer);
var
  i: integer;
begin
  inherited Create(False);
  initSize := size;
  list := TList<TRedisItem>.Create();
  for i := 0 to size - 1 do
  begin
    additem();
  end;
end;

destructor TRedisList.Destroy;
var
  i: Integer;
begin
  for i := 0 to list.Count - 1 do
  begin
    list[i].Free;
  end;
  list.Clear;
  list.Free;
  isclose := true;

  inherited;
end;

procedure TRedisList.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    Sleep(100);
    Inc(k);
    if k >= 100 then
    begin
      k := 0;
      RunClear;

    end;

  end;
end;


function TRedisList.OpenRedis: TRedisItem;
var
  i: Integer;
  isok: boolean;
begin
  Result := nil;
  isok := false;
  for i := 0 to list.Count - 1 do
  begin
    if (not list[i].isLock) and (not list[i].isdel) then
    begin
      isok := true;
      list[i].isLock := true;
      Result := list[i];
      break;
    end;
  end;
  if not isok then
  begin
    Result := additem;
  end;
end;

procedure TRedisList.RunClear;
var
  sum, index: Integer;
begin
  try
    sum := list.Count - 1;
    index := 0;
    while index < sum - initSize do
    begin
      if list[index].isdel then
      begin
        list[index].Free;
        list.Delete(index);
        break;
      end;

      index := index + 1;
    end;
  except
    on e: Exception do
    begin
      log(e.Message);
    end;
  end;

  try
    sum := list.Count - 1;
    index := 0;
    while index < sum - initSize do
    begin
      if (not list[index].isLock) and (Now() >= list[index].timerout) then
      begin
        list[index].isdel := true;
        break;
      end;
      index := index + 1;
    end;
  except
    on e: Exception do
    begin
      log(e.Message);
    end;
  end;
end;

{ TRedisItem }

constructor TRedisItem.Create();
begin
  item := TRedisM.Create();
end;

destructor TRedisItem.Destroy;
begin
  item.Free;
  inherited;
end;


procedure TRedisItem.Setguid(const Value: string);
begin
  Fguid := Value;
end;

procedure TRedisItem.Setisdel(const Value: Boolean);
begin
  Fisdel := Value;
end;

procedure TRedisItem.SetisLock(const Value: Boolean);
begin
  FisLock := Value;
end;

procedure TRedisItem.Settimerout(const Value: TDateTime);
begin
  Ftimerout := Value;
end;

end.

