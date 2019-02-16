{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit Command;

interface

uses
  System.SysUtils, System.Variants, RouleItem, System.Rtti, System.Classes, Web.HTTPApp,
  uConfig, System.DateUtils, SessionList, superobject, uInterceptor, uRouleMap,
  PackageManager;

var
  RouleMap: TRouleMap = nil;
  SessionListMap: TSessionList = nil;
  SessionName: string;
  rooturl: string;
  RTTIContext: TRttiContext;
  _Interceptor: TInterceptor;
  _PackageManager: TPackageManager = nil;

function OpenPackageConfigFile(): ISuperObject;

function OpenConfigFile(): ISuperObject;

function OpenMIMEFile(): ISuperObject;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);

function DateTimeToGMT(const ADate: TDateTime): string;

function StartServer: string;

procedure CloseServer;

procedure setDataBase(jo: ISuperObject);

implementation

uses
  wnMain, DES, LogUnit, wnDM, ThSessionClear, FreeMemory;

var
  sessionclear: TThSessionClear;
  FreeMemory: TFreeMemory;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);
var
  Action: TObject;
  ActoinClass: TRttiType;
  ActionMethod, CreateView, Interceptor: TRttiMethod;
  Response, Request, ActionPath: TRttiProperty;
  url, url1: string;
  item: TRouleItem;
  tmp: string;
  methodname: string;
  k: integer;
  ret: TValue;
  cExt: string;
  typ: string;
begin

  web.Response.ContentEncoding := default_charset;
  web.Response.Server := 'IIS/6.0';
  web.Response.Date := Now;
  url := LowerCase(web.Request.PathInfo);
  k := Pos('.', url);
  if k <= 0 then
  begin
    item := RouleMap.GetRoule(url, url1, methodname);
    if (item <> nil) then
    begin
      ActoinClass := RTTIContext.GetType(item.Action);
      ActionMethod := ActoinClass.GetMethod(methodname);
      CreateView := ActoinClass.GetMethod('CreateView');
      if item.Interceptor then
        Interceptor := ActoinClass.GetMethod('Interceptor');
      Request := ActoinClass.GetProperty('Request');
      Response := ActoinClass.GetProperty('Response');
      ActionPath := ActoinClass.GetProperty('ActionPath');
      try
        if (ActionMethod <> nil) then
        begin
          try
            Action := item.Action.Create;
            Request.SetValue(Action, web.Request);
            Response.SetValue(Action, web.Response);
            ActionPath.SetValue(Action, item.path);
            CreateView.Invoke(Action, []);
            if item.Interceptor then
            begin
              ret := Interceptor.Invoke(Action, []);
              if (not ret.AsBoolean) then
              begin
                ActionMethod.Invoke(Action, []);
              end;
            end
            else
            begin
              ActionMethod.Invoke(Action, []);
            end;
          finally
            FreeAndNil(Action);
          end;

        end
        else
        begin
          web.Response.ContentType := 'text/html; charset=' + default_charset;
          web.Response.Content := url + '  地址不存在';
          web.Response.SendResponse;
        end;
      finally
        Handled := true;
      end;
    end
    else
    begin
      web.Response.ContentType := 'text/html; charset=' + default_charset;
      web.Response.Content := url + '  地址不存在';
      web.Response.SendResponse;
    end;
  end
  else
  begin
    if (not open_debug) and open_cache then
    begin
      web.Response.SetCustomHeader('Cache-Control', 'public');
      web.Response.SetCustomHeader('Pragma', 'Pragma');
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now()));
      web.Response.SetCustomHeader('Last-Modified', tmp);
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now() + 24 * 60 * 60));
      web.Response.SetCustomHeader('Expires', tmp);
    end
    else
    begin
      web.Response.SetCustomHeader('Cache-Control', 'no-cache');
    end;
    cExt := UpperCase(ExtractFileExt(url));
    if cExt = '.JPG' then
      typ := 'image/jpeg'
    else if cExt = '.PNG' then
      typ := 'image/png'
    else if cExt = '.GIF' then
      typ := 'image/gif'
    else if cExt = '.ICO' then
      typ := 'image/x-icon'
    else if cExt = '.JS' then
      typ := 'application/x-javascript'
    else if cExt = '.CSS' then
      typ := 'text/css';
    if (typ <> '') then
      web.Response.ContentType := typ + ';';
  end;

end;

function OpenPackageConfigFile(): ISuperObject;
var
  f: TStringList;
  jo: ISuperObject;
  txt: string;
  key: string;
begin
  key := password_key;
  f := TStringList.Create;
  try
    try
      f.LoadFromFile(WebApplicationDirectory + package_config);
      txt := f.Text.Trim;
      if Trim(key) = '' then
      begin
        txt := f.Text;
      end
      else
      begin
        txt := DeCryptStr(txt, key);
      end;
      jo := SO(txt);
    except
      log(package_config + '配置文件错误,服务启动失败');
      jo := nil;
    end;
  finally
    f.Free;
  end;

  Result := jo;
end;

function OpenConfigFile(): ISuperObject;
var
  f: TStringList;
  jo: ISuperObject;
  txt: string;
  key: string;
begin
  key := password_key;
  f := TStringList.Create;
  try
    try
      f.LoadFromFile(WebApplicationDirectory + config);
      txt := f.Text.Trim;
      if Trim(key) = '' then
      begin
        txt := f.Text;
      end
      else
      begin
        txt := DeCryptStr(txt, key);
      end;
      jo := SO(txt);
      jo.O['Server'].S['Port'];
    except
      log(config + '配置文件错误,服务启动失败');
      jo := nil;
    end;
  finally
    f.Free;
  end;

  Result := jo;
end;

function OpenMIMEFile(): ISuperObject;
var
  f: TStringList;
  jo: ISuperObject;
  txt: string;
begin
  f := TStringList.Create;
  try
    try
      f.LoadFromFile(WebApplicationDirectory + mime);
      txt := f.Text.Trim;
      jo := SO(txt);
    except
      log(mime + '配置文件错误,服务启动失败');
      jo := nil;
    end;
  finally
    f.Free;
  end;

  Result := jo;
end;

function DateTimeToGMT(const ADate: TDateTime): string;
const
  WEEK: array[1..7] of PChar = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  MonthDig: array[1..12] of PChar = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
  wWeek, wYear, wMonth, wDay, wHour, wMin, wSec, wMilliSec: Word;
  sWeek, sMonth: string;
begin
  DecodeDateTime(ADate, wYear, wMonth, wDay, wHour, wMin, wSec, wMilliSec);
  wWeek := DayOfWeek(ADate);
  sWeek := WEEK[wWeek];
  sMonth := MonthDig[wMonth];
  Result := Format('%s, %.2d %s %d %.2d:%.2d:%.2d GMT', [sWeek, wDay, sMonth, wYear, wHour, wMin, wSec]);
end;

function StartServer: string;
var
  LURL: string;
  FPort: string;
  jo: ISuperObject;
begin
  jo := OpenConfigFile();
  if jo <> nil then
  begin
    //服务启动在SynWebApp查询
    if auto_free_memory then
      FreeMemory := TFreeMemory.Create(False);
    if open_package then
      _PackageManager := TPackageManager.Create;
    SessionName := '__guid_session';
    FPort := jo.O['Server'].S['Port'];
    RouleMap := TRouleMap.Create;
    SessionListMap := TSessionList.Create;
    sessionclear := TThSessionClear.Create(false);
    _Interceptor := TInterceptor.Create;
    setDataBase(jo);
    log('服务启动');
    Result := FPort;
  end;

end;

procedure CloseServer;
begin
  if SessionListMap <> nil then
  begin
    if open_package then
    begin
      _PackageManager.isstop := true;
      FreeAndNil(_PackageManager);
    end;
    FreeAndNil(_Interceptor);
    FreeAndNil(SessionListMap);
    FreeAndNil(RouleMap);
    FreeAndNil(DM);
    sessionclear.Terminate;
    FreeAndNil(sessionclear);
    if auto_free_memory then
    begin
      FreeMemory.Terminate;
      FreeAndNil(FreeMemory);
    end;

  end;
end;

procedure setDataBase(jo: ISuperObject);
var
  oParams: TStrings;
  jo1: ISuperObject;
  item: TSuperAvlEntry;
  value: string;
begin

  oParams := TStringList.Create;
  try
    jo1 := jo.O[db_type];
    for item in jo1.AsObject do
    begin
      value := item.Name + '=' + item.Value.AsString;
      oParams.Add(value);
    end;
    DM := TDM.Create(nil);
    DM.DBManager.Active := false;
    DM.DBManager.DriverDefFileName := db_type;
    DM.DBManager.AddConnectionDef(db_type, db_type, oParams);
    DM.DBManager.Active := true;
  finally
    oParams.Free;
  end;
  //这里可以连接多个其他数据源 比如同时连接 mysql 再连接 sqlserver
 // DM.DBManagerSQLServer.AddConnectionDef(db_type2, db_type2, oParams);
  //DM.DBManagerSQLServer.Active := true;
end;

end.

