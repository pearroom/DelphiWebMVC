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
  Web.HTTPApp, System.DateUtils, MVC.SessionList, XSuperObject, SynWebConfig,
  uInterceptor, uRouleMap, MVC.RedisList, MVC.LogUnit, uGlobal, uPlugin,
  System.StrUtils, MVC.PackageManager, MVC.PageCache, MVC.DM, MVC.ActionList,
  MVC.DBPool, XSuperJSON, System.Generics.Collections, IdURI;

var
  RouleMap: TRouleMap = nil;
  SessionListMap: TSessionList = nil;
  SessionName: string;
  rooturl: string;
  _Interceptor: TInterceptor;
  _RedisList: TRedisList;
  _PackageManager: TPackageManager = nil;
  _MIMEConfig: string;
  directory_permission: TDictionary<string, Boolean>;

function check_directory_permission(path: string): Boolean;

procedure SetConfig(param: ISuperObject);

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
  MVC.DES, MVC.ThSessionClear, MVC.RedisM, MVC.ActionClear, MVC.DBPoolList,
  MVC.DBPoolClear, MVC.Config, MVC.Page;

var
  sessionclear: TThSessionClear;

function check_directory_permission(path: string): Boolean;
var
  key: string;
  ret: Boolean;
begin
  Result := true;
  ret := true;
  for key in directory_permission.Keys do
  begin
    if copy(path, 0, length(key)) = key then
    begin
      directory_permission.TryGetValue(key, ret);
      Result := ret;
      break;
    end;
  end;
end;

procedure SetConfig(param: ISuperObject);
var
  jo: ISuperObject;
  s: string;
  directory: ISuperArray;
  i: integer;
  path: string;
  permission: Boolean;
begin
  with Config do
  begin
    __APP__ := '';                               // 应用名称 ,可当做虚拟目录使用
    __WebRoot__ := '.';
    template := 'view';                        // 模板根目录
    template_type := '.html';                  // 模板文件类型
    roule_suffix := '';                     // 伪静态后缀文件名
    session_start := true;                     // 启用session
    session_timer := 30;                        // session过期时间分钟
    bpl_Reload_timer := 5;                                     // bpl包检测时间间隔 默认5秒
    bpl_unload_timer := 10;                                    // bpl包卸载时间间隔 默认10秒，加载新包后等待10秒卸载旧包
    open_package := false;                                      // 使用 bpl包开发模式
    open_log := true;                          // 开启日志;open_debug=true并开启日志将在UI显示
    open_cache := true;                        // 开启缓存模式open_debug=false时有效
    cache_max_age := '315360000';                // 缓存超期时长秒
    open_interceptor := true;                 // 开启拦截器
    document_charset := 'utf-8';               // 字符集
    show_sql := false;                            //日志打印sql
    open_debug := true;                       // 开发者模式缓存功能将会失效,开启前先清理浏览器缓存
    Error404 := '';
    Error500 := '';
    JsonToLower := false;
    session_name := '__guid_session';
  end;
  jo := param.O['Config'];
  if (jo.Count > 0) then
  begin
    if jo['__APP__'] <> nil then
      Config.__APP__ := jo['__APP__'].AsString;
    if jo['__WebRoot__'] <> nil then
      Config.__WebRoot__ := jo['__WebRoot__'].AsString;
    if jo['template'] <> nil then
      Config.template := jo['template'].AsString;
    if jo['template_type'] <> nil then
      Config.template_type := jo['template_type'].AsString;
    if jo['roule_suffix'] <> nil then
      Config.roule_suffix := jo['roule_suffix'].AsString;
    if jo['session_start'] <> nil then
      Config.session_start := jo['session_start'].AsBoolean;
    if jo['session_timer'] <> nil then
      Config.session_timer := jo['session_timer'].AsInteger;
    if jo['bpl_Reload_timer'] <> nil then
      Config.bpl_Reload_timer := jo['bpl_Reload_timer'].AsInteger;
    if jo['bpl_unload_timer'] <> nil then
      Config.bpl_unload_timer := jo['bpl_unload_timer'].AsInteger;
    if jo['open_package'] <> nil then
      Config.open_package := jo['open_package'].AsBoolean;
    if jo['open_log'] <> nil then
      Config.open_log := jo['open_log'].AsBoolean;
    if jo['open_cache'] <> nil then
      Config.open_cache := jo['open_cache'].AsBoolean;
    if jo['cache_max_age'] <> nil then
      Config.cache_max_age := jo['cache_max_age'].AsString;
    if jo['open_interceptor'] <> nil then
      Config.open_interceptor := jo['open_interceptor'].AsBoolean;
    if jo['document_charset'] <> nil then
      Config.document_charset := jo['document_charset'].AsString;
    if jo['show_sql'] <> nil then
      Config.show_sql := jo['show_sql'].AsBoolean;
    if jo['open_debug'] <> nil then
      Config.open_debug := jo['open_debug'].AsBoolean;
    if jo['sessoin_name'] <> nil then
      Config.session_name := jo['sessoin_name'].AsString;
    if jo['JsonToLower'] <> nil then
      Config.JsonToLower := jo['JsonToLower'].AsBoolean;
    if jo['Error404'] <> nil then
      if jo['Error404'].AsString.Trim <> '' then
        Config.Error404 := Config.__WebRoot__ + '/' + jo['Error404'].AsString;
    if jo['Error500'] <> nil then
      if jo['Error500'].AsString.Trim <> '' then
        Config.Error500 := Config.__WebRoot__ + '/' + jo['Error500'].AsString;
    //获取访问路径权限
    directory := jo.A['directory'];
    if (directory.Length > 0) then
    begin
      if directory.DataType = TDataType.dtArray then
      begin
        for i := 0 to directory.Length - 1 do
        begin
          begin
            try
              jo := directory.O[i];
              path := jo.s['path'];
              permission := jo.B['permission'];
              directory_permission.Add(path, permission);
            except
              log('directory参数错误,服务启动失败');
              break;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);
var
  Action: TObject;
  RTTIContext: TRttiContext;
  ActoinClass: TRttiType;
  ActionMethod, SetParams, Interceptor, FreeDb: TRttiMethod;
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

  web.Response.ContentEncoding := Config.document_charset;
  web.Response.Server := 'IIS/6.0';
  web.Response.Date := Now;
  {$IFDEF MORMOT}
  url := TIdURI.URLDecode(web.Request.PathInfo);
  {$ELSE}
  url := web.Request.PathInfo;
  {$ENDIF }
  if not check_directory_permission(url) then
  begin
    Error404(web, url);
    exit;
  end;
  if Config.roule_suffix.Trim <> '' then
  begin
    if RightStr(url, Length(Config.roule_suffix)) = Config.roule_suffix then
      url := url.Replace(Config.roule_suffix, '');
  end;
  k := Pos('.', url);
  if k <= 0 then
  begin
    item := RouleMap.GetRoule(url, url1, methodname);
    if (item <> nil) then
    begin
      if (url.IndexOf('//') > -1) then
      begin
        url := url.Replace('//', '/');
        web.Response.SendRedirect(url + '/');
        exit;
      end;
      if (methodname = 'index') and (url.Substring(url.Length - 1) <> '/') then
      begin
        web.Response.SendRedirect(url + '/');
        exit;
      end;
      ActoinClass := RTTIContext.GetType(item.Action);
      ActionMethod := ActoinClass.GetMethod(methodname);
      SetParams := ActoinClass.GetMethod('SetParams');
      FreeDb := ActoinClass.GetMethod('FreeDb');
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
          //  Action := item.Action.Create;
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
            FreeDb.Invoke(Action, []);
            _ActionList.FreeAction(actionitem);
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
    if (not Config.open_debug) and Config.open_cache then
    begin
      web.Response.SetCustomHeader('Cache-Control', 'max-age=' + Config.cache_max_age);
      web.Response.SetCustomHeader('Pragma', 'Pragma');
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now()));
      web.Response.SetCustomHeader('Last-Modified', tmp);
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(IncHour(now(), 24)));
      web.Response.SetCustomHeader('Expires', tmp);
    end
    else
    begin

      web.Response.SetCustomHeader('Cache-Control', 'no-cache,no-store');
      {$IFDEF MORMOT}
      web.Response.Content := WebApplicationDirectory + Config.__WebRoot__ + url;
      web.Response.ContentType := '!STATICFILE';
      {$ENDIF}

    end;
  end;
end;

procedure Error404(web: TWebModule; url: string);
var
  s: string;
  page: Tpage;
begin
  web.Response.StatusCode := 404;
  web.Response.ContentType := 'text/html; charset=' + Config.document_charset;
  s := '<html><body><div style="text-align: left;">';
  s := s + '<div><h1>Error 404</h1></div>';
  s := s + '<hr><div>[ ' + url + ' ] Not Find Page' + '</div></div></body></html>';
  if Trim(Config.Error404) <> '' then
  begin
    if FileExists(Config.Error404) then
    begin
      page := TPage.Create(Config.Error404, nil, '');
      try
        s := page.HTML;
      finally
        page.Free;
      end;
    end;
  end;
  log('Error 404 [ ' + url + ' ] Not Find Page');
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
  key := Config.password_key;

  f := TStringList.Create;
  try
    try
      f.LoadFromFile(WebApplicationDirectory + Config.config);
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
      SetConfig(jo);
    except
      log(Config.config + '无法加载配置文件');
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
      f.LoadFromFile(WebApplicationDirectory + Config.mime);
      txt := f.Text.Trim;
      jo := SO(txt);
    except
      log(Config.mime + '无法加载配置文件');
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
  Config.config := 'resources/config.json';
  Config.mime := 'resources/mime.json';
  Config.package_config := 'resources/package.json';
  _LogList := TStringList.Create;
  _logThread := TLogTh.Create(false);
  directory_permission := TDictionary<string, Boolean>.Create;
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
        SessionName := Config.session_name;
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
        if Config.open_package then
          _PackageManager := TPackageManager.Create;
        RouleMap := TRouleMap.Create;
        SessionListMap := TSessionList.Create;
        sessionclear := TThSessionClear.Create(false);
        _Interceptor := TInterceptor.Create;
        _PageCache := TPageCache.Create;

        _ActionList := TActionList.Create;
        _ActoinClear := TActionClear.Create(False);
        _DBPoolList := TDBPoolList.Create;
        _DBPoolClear := TDBPoolClear.Create(False);
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
  directory_permission.Clear;
  directory_permission.Free;
  if _logThread <> nil then
  begin
    _logThread.Terminate;
  end;
  if sessionclear <> nil then
  begin
    sessionclear.Terminate;
  end;
  if Config.open_package and (_PackageManager <> nil) then
  begin
    _PackageManager.isstop := true;
  end;
  if _ActoinClear <> nil then
    _ActoinClear.Terminate;
  if _DBPoolClear <> nil then
    _DBPoolClear.Terminate;

  Sleep(200);

  if _logThread <> nil then
  begin
    _logThread.Free;
  end;
  if sessionclear <> nil then
  begin
    sessionclear.Free;
  end;
  if Config.open_package and (_PackageManager <> nil) then
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
  if _DBPoolList <> nil then
    _DBPoolList.Free;
  if _DBPoolClear <> nil then
    _DBPoolClear.Free;
end;

function OpenPackageConfigFile(): ISuperObject;
var
  f: TStringList;
  jo: ISuperObject;
  txt: string;
  key: string;
begin
  key := Config.password_key;
  f := TStringList.Create;
  try
    try
      f.LoadFromFile(WebApplicationDirectory + Config.package_config);
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
      log(Config.package_config + '无法加载配置文件');
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
//          if PoolSize <> '' then
//            _DbPool.AddDb(1, dbjo.CurrentKey);
          if Config.open_debug then
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

