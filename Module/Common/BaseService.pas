{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit BaseService;

interface

uses
  UsersInterface, uConfig, superobject, uTableMap, System.SysUtils, System.Classes,
  PackageManager;

type
  TBaseService = class(TInterfacedObject)
  public
    Db: TDB;
    function exec(package, classname, method: string; map: ISuperObject): ISuperObject;
    constructor Create(_Db: TDB);
  end;

implementation

uses
  LogUnit, command;

{ TBaseService }

constructor TBaseService.Create(_Db: TDB);
begin
  Db := _Db;
end;

function TBaseService.exec(package, classname, method: string; map: ISuperObject): ISuperObject;
var
  m, classname_: string;
  me: TMethod;
  fun: TPackageMethod;
  setdb: TSetDBMethod;
  isok: Boolean;
  ret: ISuperObject;
  tmpclass: TPersistent;
begin
  try
    m := _PackageManager.json_config.O[package].O[classname].s[method];
    classname_ := _PackageManager.json_config.O[package].O[classname].s['classname'];
    tmpclass := GetClass(classname_).Create as TPersistent;
    try
      try
        me.Code := tmpclass.MethodAddress('setDB');
        me.Data := Pointer(tmpclass);
        setdb := TSetDBMethod(me);
        isok := setdb(Db);
        if isok then
        begin
          me.Code := tmpclass.MethodAddress(m);
          me.Data := Pointer(tmpclass);
          fun := TPackageMethod(me);
          ret := fun(map);
        end;
      except
        on e: Exception do
        begin
          log(package + '包' + classname_ + '类' + m + '方法' + e.Message);
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
      log(package + '包' + classname_ + '类' + m + '方法' + e.Message);
      Result := nil;
    end;
  end;

end;

end.

