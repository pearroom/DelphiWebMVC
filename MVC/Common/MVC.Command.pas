{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.Command;

interface

uses
  System.SysUtils, System.Variants, MVC.RouleItem, System.Rtti, System.Classes,
  Web.HTTPApp, uConfig, System.DateUtils, MVC.SessionList, XSuperObject,
  SynWebConfig, uInterceptor, uRouleMap, MVC.RedisList, MVC.LogUnit, uGlobal,
  uPlugin, System.StrUtils, MVC.PackageManager, MVC.PageCache, MVC.DM,
  MVC.ActionList, MVC.DBPool;

var
  RouleMap: TRouleMap = nil;
  SessionListMap: TSessionList = nil;
  SessionName: string;
  rooturl: string;
  _Interceptor: TInterceptor;
  _RedisList: TRedisList;
  _PackageManager: TPackageManager = nil;
  _MIMEConfig: string;
  RTTIContext: TRttiContext;

function OpenPackageConfigFile(): ISuperObject;

function OpenConfigFile(): ISuperObject;

function OpenMIMEFile(): ISuperObject;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);

function DateTimeToGMT(const ADate: TDateTime): string;

function StartServer(): string;

procedure CloseServer();

procedure setDataBase(jo: ISuperObject);

function StrToParamTypeValue(AValue: string; AParamType: TTypeKind): TValue;

procedure Error404(web: TWebModule; url: string);

implementation

uses
  MVC.DES, MVC.ThSessionClear, MVC.RedisM, MVC.ActionClear;

var
  sessionclear: TThSessionClear;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);
var
  Action: TObject;
  ActoinClass: TRttiType;
  ActionMethod, SetParams, Interceptor: TRttiMethod;
  Response, Request, ActionPath, ActionRoule: TRttiProperty;
  url, url1: string;
  item: TRouleItem;
  tmp: string;
  methodname: string;
  k: integer;
  ret: TValue;
  s, s1: string;
  sessionid: string;
  //--------大量提供begin------------
  i: integer;
  ActionMethonValue: TRttiParameter;
  ActionMethonValues: TArray<TRttiParameter>;
  aValueArray: TArray<TValue>;
  sParameters: string;
  sValue: string;
  //-------大量提供end--------------
  params: TStringList;
  actionitem: TActionItem;
begin

  web.Response.ContentEncoding := document_charset;
  web.Response.Server := 'IIS/6.0';
  web.Response.Date := Now;
  url := LowerCase(web.Request.PathInfo);
  if roule_suffix.Trim <> '' then
  begin
    if RightStr(url, Length(roule_suffix)) = roule_suffix then
      url := url.Replace(roule_suffix, '');
  end;
  k := Pos('.', url);
  if k <= 0 then
  begin
    item := RouleMap.GetRoule(url, url1, methodname);
    if (item <> nil) then
    begin
      ActoinClass := RTTIContext.GetType(item.Action);
      ActionMethod := ActoinClass.GetMethod(methodname);
      SetParams := ActoinClass.GetMethod('SetParams');
      if item.Interceptor then
        Interceptor := ActoinClass.GetMethod('Interceptor');
      Request := ActoinClass.GetProperty('Request');
      Response := ActoinClass.GetProperty('Response');
      ActionPath := ActoinClass.GetProperty('ActionPath');
      ActionRoule := ActoinClass.GetProperty('ActionRoule');
      try
        if (ActionMethod <> nil) then
        begin
          try

            actionitem := _ActionList.Get(item.Action.ClassName);
            if actionitem = nil then
            begin
              Action := item.Action.Create;
              actionitem := _ActionList.Add(Action);
            end
            else
            begin
              Action := actionitem.Action;
            end;
           // Action := item.Action.Create;
            Request.SetValue(Action, web.Request);
            Response.SetValue(Action, web.Response);
            ActionPath.SetValue(Action, item.path);
            ActionRoule.SetValue(Action, item.Name);
            SetParams.Invoke(Action, []);

            //--------------大量提供begin----------------------
            ActionMethonValues := ActionMethod.GetParameters;
            SetLength(aValueArray, Length(ActionMethonValues));
            if Length(item.Name + methodname) = Length(url) then
            begin
              for i := Low(ActionMethonValues) to High(ActionMethonValues) do
              begin
                ActionMethonValue := ActionMethonValues[i];
                sParameters := ActionMethonValue.Name;   //参数名
                if web.Request.MethodType = mtGet then  //从web.GET中提取值
                  sValue := web.Request.QueryFields.Values[sParameters]
                else
                begin
                  sValue := web.Request.ContentFields.Values[sParameters]; //从web.POST中提取值
                  if sValue = '' then
                    sValue := web.Request.QueryFields.Values[sParameters];
                end;
                aValueArray[i] := StrToParamTypeValue(sValue, ActionMethonValue.ParamType.TypeKind); //根据参数数据类型，转换值，只传常量
              end;
            end
            else
            begin
              params := TStringList.Create;
              try
                s1 := item.Name;
                s := Copy(url, Length(s1) + 1, Length(url) - Length(s1));
                params.Delimiter := '/';
                params.DelimitedText := s;
                for i := Low(ActionMethonValues) to High(ActionMethonValues) do
                begin
                  ActionMethonValue := ActionMethonValues[i];
                  if (i < params.Count - 1) then
                    sValue := params.Strings[i + 1]
                  else
                    sValue := '';
                  aValueArray[i] := StrToParamTypeValue(sValue, ActionMethonValue.ParamType.TypeKind); //根据参数数据类型，转换值，只传常量
                end;
              finally
                params.Free;
              end;
            end;

            //-----------------大量提供end------------------------
            if item.Interceptor then
            begin
              ret := Interceptor.Invoke(Action, []);
              if (not ret.AsBoolean) then
              begin
                ActionMethod.Invoke(Action, aValueArray);
              end;
            end
            else
            begin
              ActionMethod.Invoke(Action, aValueArray);
              if web.Response.ContentType = '' then
                Error404(web, url);
            end;
          finally
            actionitem.isStop := 1;
           // Action.Free;
          end;
        end
        else
        begin
          Error404(web, url);
        end;
      finally
        Handled := true;
      end;
    end
    else
    begin
      Error404(web, url);
    end;
  end
  else
  begin
    if (not open_debug) and open_cache then
    begin
      web.Response.SetCustomHeader('Cache-Control', 'max-age=' + cache_max_age);
      web.Response.SetCustomHeader('Pragma', 'Pragma');
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now()));
      web.Response.SetCustomHeader('Last-Modified', tmp);
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(IncHour(now(), 24)));
      web.Response.SetCustomHeader('Expires', tmp);
    end
    else
    begin
      web.Response.SetCustomHeader('Cache-Control', 'no-cache,no-store');
    end;
  end;
end;

procedure Error404(web: TWebModule; url: string);
var
  s: string;
begin
  web.Response.StatusCode := 404;
  web.Response.ContentType := 'text/html; charset=' + document_charset;
  s := '<html><body><div style="text-align: left;">';
  s := s + '<div><h1>Error 404</h1></div>';
  s := s + '<hr><div>[ ' + url + ' ] Not Find Page' + '</div></div></body></html>';
  web.Response.Content := s;
  web.Response.SendResponse;
end;

function StrToParamTypeValue(AValue: string; AParamType: TTypeKind): TValue;
begin
  case AParamType of
    tkInteger, tkInt64:
      begin
        try
          if AValue.Trim = '' then
            AValue := '0';
          Result := StrToInt(AValue);
        except
          Result := 0;
        end;
      end;
    tkFloat:
      begin
        try
          if AValue.Trim = '' then
            AValue := '0';
          Result := StrToFloat(AValue);
        except
          Result := 0;
        end;
      end;
    tkString, tkChar, tkWChar, tkLString, tkWString, tkUString, tkVariant:
      begin
        Result := AValue;
      end;
  else
    begin
      Result := AValue;
      //其他类型暂时用不到，先不考虑转换
    end;
//    tkUnknown:;
//    tkEnumeration:;
//    tkSet:;
//    tkClass:;
//    tkMethod:;
//    tkArray:;
//    tkRecord:;
//    tkInterface:;
//    tkDynArray:;
//    tkClassRef:;
//    tkPointer:;
//    tkProcedure:;
//    tkMRecord:;
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
      txt := jo.AsJSON();
      jo.O['Server'].s['Port'];
    except
      log(config + '无法加载配置文件');
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
      log(mime + '无法加载配置文件');
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

function StartServer(): string;
var
  FPort: string;
  jo: ISuperObject;
begin
  _LogList := TStringList.Create;
  _logThread := TLogTh.Create(false);
  FPort := '0000';
  try
    try
      _MIMEConfig := OpenMIMEFile.AsJSON();
      jo := OpenConfigFile();
      if jo <> nil then
      begin
        FPort := jo.O['Server'].s['Port'];
      //////////////////////////////////////////
        syn_Port := FPort;
        syn_Compress := jo.O['Server'].s['Compress'];
        syn_HTTPQueueLength := jo.O['Server'].i['HTTPQueueLength'];
        syn_ChildThreadCount := jo.O['Server'].i['ChildThreadCount'];
        ////////////////////////////////////////////////////
        SessionName := '__guid_session';
        _RedisList := nil;
        if jo.O['Redis'] <> nil then
        begin
          Redis_IP := jo.O['Redis'].s['Host'];
          Redis_Port := jo.O['Redis'].i['Port'];
          Redis_PassWord := jo.O['Redis'].s['PassWord'];
          Redis_InitSize := jo.O['Redis'].i['InitSize'];
          Redis_TimeOut := jo.O['Redis'].i['TimeOut'];
          Redis_ReadTimeOut := jo.O['Redis'].i['ReadTimeOut'];
          if redis_ip <> '' then
          begin
            _RedisList := TRedisList.Create(Redis_InitSize);
          end;
        end;
        Global := TGlobal.Create;
        if open_package then
          _PackageManager := TPackageManager.Create;
        RouleMap := TRouleMap.Create;
        SessionListMap := TSessionList.Create;
        sessionclear := TThSessionClear.Create(false);
        _Interceptor := TInterceptor.Create;
        _PageCache := TPageCache.Create;
        _ActionList := TActionList.Create;
        _ActoinClear := TActionClear.Create(False);
        setDataBase(jo);
        log('StartService Port:' + FPort);
        AppRun := True;
      end
      else
      begin
        log('Config.json:Error');
      end;
    except
      log('Config.json:Error');
    end;
  finally
    Result := FPort;
  end;
end;

procedure CloseServer();
begin
  AppClose := true;
  if _logThread <> nil then
  begin
    _logThread.Terminate;
  end;
  if sessionclear <> nil then
  begin
    sessionclear.Terminate;
  end;
  if open_package and (_PackageManager <> nil) then
  begin
    _PackageManager.isstop := true;
  end;
  if _ActoinClear <> nil then
    _ActoinClear.Terminate;
  Sleep(200);

  if _logThread <> nil then
  begin
    _logThread.Free;
  end;
  if sessionclear <> nil then
  begin
    sessionclear.Free;
  end;
  if open_package and (_PackageManager <> nil) then
  begin
    _PackageManager.Free;
  end;
  if _LogList <> nil then
  begin
    _LogList.Clear;
    _LogList.Free;
  end;
  if _Interceptor <> nil then
    _Interceptor.Free;
  if SessionListMap <> nil then
    SessionListMap.Free;
  if RouleMap <> nil then
    RouleMap.Free;
  if MVCDM <> nil then
    MVCDM.Free;
  if _RedisList <> nil then
    _RedisList.Free;
  if Global <> nil then
    Global.Free;
  if _PageCache <> nil then
    _PageCache.Free;
  if _DbPool <> nil then
    _DbPool.Free;
  if _ActoinClear <> nil then
    _ActoinClear.Free;
  if _ActionList <> nil then
    _ActionList.Free;
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
      log(package_config + '无法加载配置文件');
      jo := nil;
    end;
  finally
    f.Free;
  end;

  Result := jo;
end;

procedure setDataBase(jo: ISuperObject);
var
  oParams: TStrings;
  dbjo, jo1, jo2, jolib: ISuperObject;
  value: string;
  DriverID: string;
  PoolSize: string;
begin
  MVCDM := TMVCDM.Create(nil);
  _DbPool := TDBPool.Create;
  MVCDM.DBManager.Active := false;
  try
    try
      jolib := jo.O['VendorLib'];
      if jolib <> nil then
      begin
        MVCDM.MySQLDriver.VendorLib := jolib.S['MYSQL'];
        MVCDM.FDPhysSQLiteDriverLink1.VendorLib := jolib.S['SQLite'];
        MVCDM.FDPhysMSSQLDriverLink1.VendorLib := jolib.S['MSSQL'];
        MVCDM.FDPhysOracleDriverLink1.VendorLib := jolib.S['ORACLE'];
        MVCDM.FDPhysFBDriverLink1.VendorLib := jolib.S['FireBird'];
      end;
      jo2 := jo.O['DBConfig'];
      value := jo2.AsJSON();
      dbjo := so(value);
      if dbjo <> nil then
      begin
        dbjo.First;
        while not dbjo.EoF do
        begin
          oParams := TStringList.Create;
          jo1 := dbjo.O[dbjo.CurrentKey];
          jo1.First;
          while not jo1.EoF do
          begin
            value := jo1.CurrentKey.Trim + '=' + Trim(VarToStr(jo1.CurrentValue.AsVariant));
            oParams.Add(value);
            if jo1.CurrentKey = 'DriverID' then
              DriverID := VarToStr(jo1.CurrentValue.AsVariant);
            if jo1.CurrentKey = 'POOL_MaximumItems' then
              PoolSize := VarToStr(jo1.CurrentValue.AsVariant);
            jo1.Next;
          end;

          MVCDM.DBManager.AddConnectionDef(dbjo.CurrentKey, DriverID, oParams);
          if PoolSize <> '' then
            _DbPool.AddDb(1, dbjo.CurrentKey);
          if open_debug then
            log('数据库配置:' + oParams.Text);
          oParams.Free;
          dbjo.Next;
        end;
      end;
    except
      log('数据库配置参数错误,请检测配置文件');
    end;
  finally
    MVCDM.DBManager.Active := true;
  end;
end;

end.

