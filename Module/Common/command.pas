unit Command;

interface

uses
  System.SysUtils, System.Variants, RouleItem, System.Rtti, System.Classes, Web.HTTPApp,
  uConfig, System.DateUtils, SessionList, MSScriptControl_TLB, superobject,
  uInterceptor, uRouleMap;

var
  RouleMap: TRouleMap = nil;
  SessionListMap: TSessionList = nil;
  SessionName: string;
  _Interceptor: TInterceptor;
  rooturl: string;
  RTTIContext: TRttiContext;

function OpenConfigFile(): ISuperObject;

function OpenMIMEFile(): ISuperObject;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);

function DateTimeToGMT(const ADate: TDateTime): string;

procedure log(msg: string);

implementation

uses
  wnMain, DES;

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
            CreateView.Invoke(Action, []); // 执行 Action CreateView 方法
            ret := Interceptor.Invoke(Action, []);
            if (not ret.AsBoolean) then
            begin
              ActionMethod.Invoke(Action, []); // 执行 Action ActionMethod 方法
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
      log('配置文件错误,服务启动失败');
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
      log('MIME配置文件错误,服务启动失败');
      jo := nil;
    end;
  finally
    f.Free;
  end;

  Result := jo;
end;

procedure log(msg: string);
var
  log: string;
  tf: TextFile;
  logfile: string;
  fi: THandle;
begin
  if open_log then
  begin
  //  CoInitialize(nil);
    try
      log := FormatDateTime('yyyy-MM-dd hh:mm:ss', Now) + #13#10 + msg;
      if Main.mmolog.Lines.Count > 1000 then
        main.mmolog.Clear;
      Main.mmolog.Lines.Add(log);
      logfile := WebApplicationDirectory + 'log\';
      if not DirectoryExists(logfile) then
      begin
        CreateDir(logfile);
      end;
      logfile := logfile + 'log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';

      AssignFile(tf, logfile);
      if FileExists(logfile) then
      begin
        Append(tf);
      end
      else
      begin
        fi := FileCreate(logfile);
        FileClose(fi);
        Rewrite(tf);
      end;
      Writeln(tf, log);
      Flush(tf);
      CloseFile(tf);
    finally
   //   CoUnInitialize;
    end;
  end;
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

end.

