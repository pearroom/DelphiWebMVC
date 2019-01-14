unit PackageManager;

interface

uses
  System.SysUtils, System.Classes, Generics.Collections, superobject, uConfig;

type
  TPackageMethod = function(Db: TDB; map: ISuperObject): ISuperObject of object;

type
  TPackageManager = class
  private
    json_config: ISuperObject;
    PackageList: TList<HModule>;
    procedure init();
    procedure reload;
  public
    function exec(package: string; classname: string; method: string; Db: TDB; map: ISuperObject): ISuperObject;
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
var
  I: Integer;
begin
  for I := 0 to PackageList.Count - 1 do
  begin
    UnloadPackage(PackageList[I]);
  end;
  PackageList.Clear;
  PackageList.Free;
  inherited;
end;

function TPackageManager.exec(package, classname, method: string; Db: TDB; map: ISuperObject): ISuperObject;
var
  m: string;
  me: TMethod;
  fun: TPackageMethod;
  ret: ISuperObject;
  tmpclass: TPersistent;
begin
  try
    m := json_config.O[package].O[classname].s[method];
    tmpclass := GetClass(classname).Create as TPersistent;
    try
      try
        me.Code := tmpclass.MethodAddress(m);
        me.Data := Pointer(tmpclass);
        fun := TPackageMethod(me);
        ret := fun(Db, map);
      except
        on e: Exception do
        begin
          log(e.Message);
          Result := nil;
        end;

      end;
      Result := ret;
    finally
      tmpclass.Free;
    end;
  except
    on e: Exception do
    begin
      log(e.Message);
      Result := nil;
    end;
  end;

end;

procedure TPackageManager.init;
var
  item: TSuperAvlEntry;
  jo: ISuperObject;
  s: string;
  PackageModule: HModule;
begin
  PackageList := TList<HModule>.Create;
  json_config := OpenPackageConfigFile();
  for item in json_config.AsObject do
  begin
    jo := SO(item.Value.AsString);
    s := jo.S['package'];

    try
      PackageModule := LoadPackage(s);
      PackageList.Add(PackageModule);
    except
      on e: Exception do
      begin
        log(e.Message);
        break;
      end;

    end;
  end;
end;
procedure TPackageManager.reload;
var
  item: TSuperAvlEntry;
  jo: ISuperObject;
  s: string;
  PackageModule: HModule;
  json:ISuperObject;
begin
  PackageList := TList<HModule>.Create;
  json := OpenPackageConfigFile();
  for item in json.AsObject do
  begin
    jo := SO(item.Value.AsString);
    s := jo.S['package'];

    try
      PackageModule := LoadPackage(s);
      PackageList.Add(PackageModule);
    except
      on e: Exception do
      begin
        log(e.Message);
        break;
      end;

    end;
  end;
end;
end.

