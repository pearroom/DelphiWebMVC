{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.BaseService;

interface

uses
  uConfig, xsuperobject, uTableMap, System.SysUtils, System.Classes,
  MVC.PackageManager, uDBConfig;

type
  TBaseService = class(TInterfacedObject)
  private
  public
    Db: TDBConfig;
    function fail(code: Integer = -1; msg: string = 'fail'): isuperobject;
    function success(code: Integer = 0; msg: string = 'success'): isuperobject;
    function Q(str: string): string;
    function exec(package, classname, method: string; map: ISuperObject): ISuperObject;
    constructor Create(_Db: TDBConfig);
  end;

implementation

uses
  MVC.LogUnit, MVC.Command;

{ TBaseService }
function TBaseService.success(code: Integer; msg: string): isuperobject;
var
  ret: ISuperObject;
begin
  ret := SO();
  ret.I['code'] := code;
  ret.S['message'] := msg;
  Result := ret;
end;

function TBaseService.fail(code: Integer; msg: string): isuperobject;
var
  ret: ISuperObject;
begin
  ret := SO();
  ret.I['code'] := code;
  ret.S['message'] := msg;
  Result := ret;
end;

constructor TBaseService.Create(_Db: TDBConfig);
begin
  Db := _Db;
end;

function TBaseService.Q(str: string): string;
begin
  result := '''' + str + '''';
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

