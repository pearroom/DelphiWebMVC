{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit PackageManager;

interface

uses
  System.SysUtils, System.Classes, Generics.Collections, superobject, uConfig;

type
  TPackageMethod = function(map: ISuperObject): ISuperObject of object;

  TSetDBMethod = function(Db: TDB): Boolean of object;

type
  TPack = class
  private
    FPackHander: HModule;
    FPackName: string;
    FVer: string;
    FisStop: Boolean;
    procedure SetPackHander(const Value: HModule);
    procedure SetPackName(const Value: string);
    procedure SetVer(const Value: string);
    procedure SetisStop(const Value: Boolean);
  published
    property PackName: string read FPackName write SetPackName;
    property PackHander: HModule read FPackHander write SetPackHander;
    property Ver: string read FVer write SetVer;
    property isStop: Boolean read FisStop write SetisStop;
  end;

type
  TPackageManager = class
  private
    isok: Boolean;
    PackageList: TList<TPack>;
    procedure init();
    procedure reload;
    function findpk(packanme, ver: string): TPack;
    procedure removepk;
  public
    isstop: boolean;
    json_config: ISuperObject;
    constructor Create();
    destructor Destroy; override;
  end;

implementation

uses
  LogUnit, command;

{ TPackageManager }

constructor TPackageManager.Create();
begin

  init();
end;

destructor TPackageManager.Destroy;
begin
  while PackageList.Count > 0 do
  begin
    UnloadPackage(PackageList[0].PackHander);
    PackageList[0].Free;
    PackageList.Delete(0);
  end;
  PackageList.Free;
  inherited;
end;

function TPackageManager.findpk(packanme, ver: string): TPack;
var
  i: Integer;
  pk: TPack;
begin
  Result := nil;
  for i := 0 to PackageList.Count - 1 do
  begin
    pk := PackageList[i];
    if (pk.PackName = packanme) and (pk.ver = ver) then
    begin
      Result := pk;
      break;
    end;
  end;
end;

procedure TPackageManager.init;
var
  item: TSuperAvlEntry;
  jo: ISuperObject;
  s: string;
  PackageModule: HModule;
  pk: TPack;
begin
  PackageList := TList<TPack>.Create;
  json_config := OpenPackageConfigFile();
  for item in json_config.AsObject do
  begin
    jo := SO(item.Value.AsString);
    s := jo.S['package'];

    try
      pk := TPack.Create;
      pk.Ver := jo.S['ver'];
      PackageModule := LoadPackage(s);
      pk.PackName := s;
      pk.PackHander := PackageModule;
      PackageList.Add(pk);
    except
      on e: Exception do
      begin
        log(e.Message);
        break;
      end;

    end;
  end;
  TThread.CreateAnonymousThread(
    procedure
    var
      k: integer;
    begin
      isok := true;
      k := 0;
      while not isstop do
      begin
        sleep(100);
        inc(k);
        if k > bpl_Reload_timer * 10 then
        begin
          k := 0;
          if isok then
          begin
            TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                reload();
              end);

          end;
        end;
      end;
    end).start();
end;

procedure TPackageManager.reload;
var
  item: TSuperAvlEntry;
  jo: ISuperObject;
  s: string;
  PackageModule: HModule;
  json: ISuperObject;
  pk, tmppk: TPack;
  findstop: Boolean;
  ver_old, ver_new: string;
begin
  findstop := false;

  json := OpenPackageConfigFile();
  for item in json_config.AsObject do
  begin

    jo := SO(item.Value.AsString);
    ver_new := json.O[item.Name].s['ver'];
    ver_old := jo.S['ver'];
    if ver_old <> ver_new then
    begin
      s := json.O[item.Name].s['package'];
      tmppk := findpk(s, ver_old);
      if tmppk <> nil then
      begin
        tmppk.isStop := true;
        findstop := true;
      end;

      try
        pk := TPack.Create;
        pk.Ver := jo.S['ver'];
        PackageModule := LoadPackage(s);
        pk.PackName := s;
        pk.PackHander := PackageModule;
        PackageList.Add(pk);

      except
        on e: Exception do
        begin
          log(e.Message);
          break;
        end;

      end;
    end;
  end;

  if findstop then
  begin
    json_config := OpenPackageConfigFile();
    isok := False;
    TThread.CreateAnonymousThread(

      procedure
      var
        k: integer;
      begin
        k := 0;
        while not isstop do
        begin
          sleep(100);
          inc(k);
          if k >= bpl_unload_timer * 10 then
          begin
            TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                removepk;
                isok := true;
              end);
            break;
          end;
        end;

      end).Start;
  end;
end;

procedure TPackageManager.removepk;
var
  i, n: Integer;
  loop: boolean;
begin

  loop := true;
  while loop do
  begin
    loop := False;
    for i := 0 to PackageList.Count - 1 do
    begin
      if PackageList[i].isStop then
      begin
        loop := True;
        UnloadPackage(PackageList[i].PackHander);
        PackageList[i].Free;
        PackageList.Delete(i);
        Break;
      end;
    end;
  end;
end;

{ TPack }

procedure TPack.SetisStop(const Value: Boolean);
begin
  FisStop := Value;
end;

procedure TPack.SetPackHander(const Value: HModule);
begin
  FPackHander := Value;
end;

procedure TPack.SetPackName(const Value: string);
begin
  FPackName := Value;
end;

procedure TPack.SetVer(const Value: string);
begin
  FVer := Value;
end;

end.

