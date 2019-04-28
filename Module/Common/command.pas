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
  RedisList, LogUnit;

var
  RouleMap: TRouleMap = nil;
  SessionListMap: TSessionList = nil;
  SessionName: string;
  rooturl: string;
  RTTIContext: TRttiContext;
  _Interceptor: TInterceptor;
  _RedisList: TRedisList;

function OpenConfigFile(): ISuperObject;

function OpenMIMEFile(): ISuperObject;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);

function DateTimeToGMT(const ADate: TDateTime): string;

function StartServer: string;

procedure CloseServer;

procedure setDataBase(jo: ISuperObject);

implementation

uses
  wnMain, DES, wnDM, ThSessionClear, FreeMemory, RedisM;

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
  s: string;
  sessionid: string;
begin

  web.Response.ContentEncoding := document_charset;
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
          web.Response.ContentType := 'text/html; charset=' + document_charset;
          s := '<html><body><div style="text-align: left;">';
          s := s + '<div><h1>Error 404</h1></div>';
          s := s + '<hr><div>[ ' + url + ' ] Not Find Page' + '</div></div></body></html>';
          web.Response.Content := s;
          web.Response.SendResponse;
        end;
      finally
        Handled := true;
      end;
    end
    else
    begin
      web.Response.ContentType := 'text/html; charset=' + document_charset;
      s := '<html><body><div style="text-align: left;">';
      s := s + '<div><h1>Error 404</h1></div>';
      s := s + '<hr><div>[ ' + url + ' ] Not Find Page' + '</div></div></body></html>';
      web.Response.Content := s;
      web.Response.SendResponse;
    end;
  end
  else
  begin
    if (not open_debug) and open_cache then
    begin
      web.Response.SetCustomHeader('Cache-Control', 'max-age='+cache_max_age);
      web.Response.SetCustomHeader('Pragma', 'Pragma');
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now()));
      web.Response.SetCustomHeader('Last-Modified', tmp);
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now() + 24 * 60 * 60));
      web.Response.SetCustomHeader('Expires', tmp);
    end
    else
    begin
      web.Response.SetCustomHeader('Cache-Control', 'no-cache,no-store');
    end;
  end;

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
      jo.O['Server'].s['Port'];
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
    _LogList := TStringList.Create;
    _logThread := TLogTh.Create(false);
    SessionName := '__guid_session';
    FPort := jo.O['Server'].s['Port'];
    _RedisList := nil;
    if jo.O['Redis'] <> nil then
    begin
      Redis_IP := jo.O['Redis'].s['Host'];
      Redis_Port := jo.O['Redis'].I['Port'];
      Redis_PassWord := jo.O['Redis'].s['PassWord'];
      Redis_InitSize := jo.O['Redis'].I['InitSize'];
      Redis_TimerOut := jo.O['Redis'].I['TimerOut'];
      if redis_ip <> '' then
      begin
        _RedisList := TRedisList.Create(Redis_InitSize);
      end;
    end;
    if auto_free_memory then
      FreeMemory := TFreeMemory.Create(False);
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
    _LogList.Clear;
    _LogList.Free;
    _logThread.Terminate;
    Sleep(100);
    _logThread.Free;
    _Interceptor.Free;
    SessionListMap.Free;
    RouleMap.Free;
    DM.Free;
    sessionclear.Terminate;
    Sleep(100);
    sessionclear.Free;
    if auto_free_memory then
    begin
      FreeMemory.Terminate;
      Sleep(100);
      FreeMemory.Free;
    end;
    if _RedisList <> nil then
      _RedisList.Free;
  end;
end;

procedure setDataBase(jo: ISuperObject);
var
  oParams: TStrings;
  dbjo, jo1: ISuperObject;
  dbitem, item: TSuperAvlEntry;
  value: string;
begin
  DM := TDM.Create(nil);
  DM.DBManager.Active := false;

  try
    dbjo := jo.O['DBConfig'];
    if dbjo <> nil then
    begin

      for dbitem in dbjo.AsObject do
      begin
        oParams := TStringList.Create;
        jo1 := dbjo.O[dbitem.Name];
        for item in jo1.AsObject do
        begin
          value := item.Name + '=' + item.Value.AsString;
          oParams.Add(value);
        end;
        DM.DBManager.AddConnectionDef(dbitem.Name, dbitem.Name, oParams);
        log('数据库配置:'+oParams.Text);
        oParams.Free;
      end;
    end;
  finally
    DM.DBManager.Active := true;

  end;

end;

end.

