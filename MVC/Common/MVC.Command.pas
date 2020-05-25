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
  System.SysUtils, System.Variants, MVC.RouteItem, System.Rtti, System.Classes,
  Web.HTTPApp, System.DateUtils, MVC.SessionList, XSuperObject, SynWebConfig,
  uInterceptor, uRouteMap, MVC.RedisList, MVC.LogUnit, uGlobal, uPlugin,
  System.StrUtils, MVC.PackageManager, MVC.PageCache, MVC.DM, XSuperJSON,
  System.Generics.Collections, Web.WebReq,
  {$IFDEF MSWINDOWS} MVC.Main, Vcl.Forms, Winapi.Windows,
  {$IFDEF CROSS} CrossWebApp, {$ELSE} SynWebApp, {$ENDIF}
  {$ELSE} CrossWebApp, {$ENDIF}IdURI, MVC.JWT;

type
  TMVCFun = class
  private
    isShow: boolean;
    PageList: TStringList;
    procedure showpagelist();
  public
    function RunCommand(): Boolean;
    procedure Run(title: string = '');
    constructor Create;
    destructor Destroy; override;
  end;

var
 // _RTTIContext: TRttiContext;
  _MVCFun: TMVCFun;
  _RouteMap: TRouteMap = nil;
  _SessionListMap: TSessionList = nil;
  _SessionName: string;
  _rooturl: string;
  _Interceptor: TInterceptor;
  _RedisList: TRedisList;
  _PackageManager: TPackageManager = nil;
  _MIMEConfig: string;
  _directory_permission: TDictionary<string, Boolean>;
  _ConfigJSON: ISuperObject;
  _mime: TDictionary<string, string>;

function check_directory_permission(path: string): Boolean;

procedure SetConfig(param: ISuperObject);

function OpenPackageConfigFile(): ISuperObject;

function OpenConfigFile(): ISuperObject;

function OpenMIMEFile(): ISuperObject;

procedure OpenRoute(_Request: TWebRequest; _Response: TWebResponse; RouteMap_: TRouteMap; var Handled: boolean);

function DateTimeToGMT(const ADate: TDateTime): string;

function StartServer(): string;

procedure CloseServer();

procedure setDataBase(jo: ISuperObject);

function StrToParamTypeValue(AValue: string; AParamType: TTypeKind): TValue;

procedure Error404(Response: TWebResponse; url: string);

procedure CreateRouteMap();

function getMimeType(extension: string): string;

implementation

uses
  MVC.DES, MVC.RedisM, MVC.DBPoolList, MVC.Config, MVC.Page, MVC.BaseController;

procedure CreateRouteMap();
begin
  if not Assigned(_RouteMap) then
    _RouteMap := TRouteMap.Create;
end;

function check_directory_permission(path: string): Boolean;
var
  key: string;
  ret: Boolean;
begin
  Result := true;
  ret := true;
  MonitorEnter(_directory_permission);
  try
    for key in _directory_permission.Keys do
    begin
      if copy(path, 0, length(key)) = key then
      begin
        _directory_permission.TryGetValue(key, ret);
        Result := ret;
        break;
      end;
    end;
  finally
    MonitorExit(_directory_permission);
  end;
end;

procedure SetConfig(param: ISuperObject);
var
  jo, jo_tmp: ISuperObject;
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
    route_suffix := '';                     // 伪静态后缀文件名
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
    Corss_Origin.Allow_Origin := '';											//跨域访问默认关闭
    Corss_Origin.Allow_Headers := '';											//跨域 头信息 Origin, X-Requested-With
    Corss_Origin.Allow_Method := '';											//跨域 方法 get, post
    Corss_Origin.Allow_Credentials := false;

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
    if jo['route_suffix'] <> nil then
      Config.route_suffix := jo['route_suffix'].AsString;
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
    if (jo['Corss_Origin']<>nil) then
    if (jo['Corss_Origin'].DataType = dtObject) then
    begin
      jo_tmp := jo['Corss_Origin'].AsObject;
      if (jo_tmp['Allow_Origin'] <> nil) then
        Config.Corss_Origin.Allow_Origin := jo_tmp['Allow_Origin'].AsString;
      if (jo_tmp['Allow_Headers'] <> nil) then
        Config.Corss_Origin.Allow_Headers := jo_tmp['Allow_Headers'].AsString;
      if (jo_tmp['Allow_Method'] <> nil) then
        Config.Corss_Origin.Allow_Method := jo_tmp['Allow_Method'].AsString;
      if (jo_tmp['Allow_Credentials'] <> nil) then
        Config.Corss_Origin.Allow_Credentials := jo_tmp['Allow_Credentials'].AsBoolean;
    end;

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
              _directory_permission.Add(path, permission);
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

procedure OpenRoute(_Request: TWebRequest; _Response: TWebResponse; RouteMap_: TRouteMap; var Handled: boolean);
var
  Action: TObject;
  Attribute: TCustomAttribute;
  ActoinClass: TRttiType;
  ActionMethod, SetParams, Interceptor, FreeDb, ShowHTML: TRttiMethod;
  Response, Request, ActionPath, ActionRoute: TRttiProperty;
  url, url1: string;
  item: TRouteItem;
  tmp: string;
  methodname: string;
  k: integer;
  ret: TValue;
  s, s1: string;
  sessionid: string;
  InterceptorMethod: Boolean;
  //--------大量提供begin------------
  i: integer;
  ActionMethonValue: TRttiParameter;
  ActionMethonValues: TArray<TRttiParameter>;
  aValueArray: TArray<TValue>;
  sParameters: string;
  sValue: string;
  //-------大量提供end--------------
  params: TStringList;
  assets: TMemoryStream;
  assetsfile: string;
  extension: string;
begin
  Handled := true;

  _Response.ContentEncoding := Config.document_charset;
  _Response.Server := 'IIS/6.0';
  _Response.Date := Now;
  {$IFDEF CROSS}
  url := _Request.PathInfo;
  {$ELSE}
  {$IFDEF MSWINDOWS}
  url := TIdURI.URLDecode(_Request.PathInfo);
  {$ELSE}
  url := _Request.PathInfo;
  {$ENDIF }
  {$ENDIF}

  if Config.__APP__ <> '' then
  begin
    url := url.Replace(Config.__APP__, '').Replace('//', '/');
  end;

  if not check_directory_permission(url) then
  begin
    Error404(_Response, url);
    exit;
  end;
  if Config.route_suffix.Trim <> '' then
  begin
    if RightStr(url, Length(Config.route_suffix)) = Config.route_suffix then
      url := url.Replace(Config.route_suffix, '');
  end;

  k := Pos('.', url);
  if k <= 0 then
  begin
    item := RouteMap_.GetRoute(url, url1, methodname);
    if (item <> nil) then
    begin
      if (url.IndexOf('//') > -1) then
      begin
        url := url.Replace('//', '/');
        _Response.SendRedirect(url);
        _Response.SendResponse;
        exit;
      end;
      if (item.Name <> '/') and (methodname = 'index') and (url.Substring(url.Length - 1) <> '/') then
      begin
        _Response.SendRedirect(url + '/');
        _Response.SendResponse;
        exit;
      end;
      InterceptorMethod := item.isInterceptor;
      ActoinClass := item.ActoinClass; // _RTTIContext.GetType(item.Action);
      ActionMethod := item.ActionMethod(methodname); //ActoinClass.GetMethod(methodname);
      if ActionMethod <> nil then
      begin
        for Attribute in ActionMethod.GetAttributes do
        begin
          if Attribute is TInterceptOfMethod then
          begin
            InterceptorMethod := (TInterceptOfMethod(Attribute)).isInterceptor;
          end;
        end;
      end;
      SetParams := item.SetParams; // ActoinClass.GetMethod('SetParams');
      FreeDb := item.FreeDb; // ActoinClass.GetMethod('FreeDb');
      ShowHTML := item.ShowHTML; // ActoinClass.GetMethod('ShowHTML');

      Interceptor := item.Interceptor; // ActoinClass.GetMethod('Interceptor');
      Request := item.Request; // ActoinClass.GetProperty('Request');
      Response := item.Response; // ActoinClass.GetProperty('Response');
      ActionPath := item.ActionPath; // ActoinClass.GetProperty('ActionPath');
      ActionRoute := item.ActionRoute; // ActoinClass.GetProperty('ActionRoute');
      try
        Action := item.Action.Create;
        Request.SetValue(Action, _Request);
        Response.SetValue(Action, _Response);
        ActionPath.SetValue(Action, item.path);
        ActionRoute.SetValue(Action, item.Name);
        SetParams.Invoke(Action, []);
        if (ActionMethod <> nil) then
        begin
          try
            //--------------大量提供begin----------------------
            ActionMethonValues := ActionMethod.GetParameters;
            SetLength(aValueArray, Length(ActionMethonValues));
            if Length(item.Name + methodname) = Length(url) then
            begin
              for i := Low(ActionMethonValues) to High(ActionMethonValues) do
              begin
                ActionMethonValue := ActionMethonValues[i];
                sParameters := ActionMethonValue.Name;   //参数名
                if _Request.MethodType = mtGet then  //从web.GET中提取值
                  sValue := _Request.QueryFields.Values[sParameters]
                else
                begin
                  sValue := _Request.ContentFields.Values[sParameters]; //从web.POST中提取值
                  if sValue = '' then
                    sValue := _Request.QueryFields.Values[sParameters];
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
            if InterceptorMethod then
            begin
              ret := Interceptor.Invoke(Action, []);
              if (not ret.AsBoolean) then
              begin
                ActionMethod.Invoke(Action, aValueArray);
                if _Response.ContentType = '' then      //默认输出html页面
                  ShowHTML.Invoke(Action, [methodname]);
              end
              else
              begin
                if _Response.Content = '' then
                begin
                  Error404(_Response, url);
                end;
                _Response.SendResponse;
              end;
            end
            else
            begin
              ActionMethod.Invoke(Action, aValueArray);
              if _Response.ContentType = '' then      //默认输出html页面
                ShowHTML.Invoke(Action, [methodname]);
            end;
          finally

          end;
        end
        else
        begin
          if InterceptorMethod then
          begin
            ret := Interceptor.Invoke(Action, []);
            if (not ret.AsBoolean) then
            begin
              if _Response.ContentType = '' then      //默认输出html页面
                ShowHTML.Invoke(Action, [methodname]);
            end
            else
            begin
              if _Response.Content = '' then
              begin
                Error404(_Response, url);
              end;
            end;
          end
          else
          begin
            if _Response.ContentType = '' then      //默认输出html页面
              ShowHTML.Invoke(Action, [methodname]);
          end;
        end;
      finally
        FreeDb.Invoke(Action, []);
        Action.Free;
      end;
    end
    else
    begin
      Error404(_Response, url);
    end;
  end
  else
  begin
    if (not Config.open_debug) and Config.open_cache then   //开启缓存
    begin
      _Response.SetCustomHeader('Cache-Control', 'max-age=' + Config.cache_max_age);
      _Response.SetCustomHeader('Pragma', 'Pragma');
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now()));
      _Response.SetCustomHeader('Last-Modified', tmp);
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(IncHour(now(), 24)));
      _Response.SetCustomHeader('Expires', tmp);
    end
    else
    begin
      _Response.SetCustomHeader('Cache-Control', 'no-cache,no-store'); //不使用缓存
    end;
    assetsfile := WebApplicationDirectory + Config.__WebRoot__ + url;
    if FileExists(assetsfile) then
    begin
      assets := TMemoryStream.Create;
      if Pos('?', assetsfile) > 0 then
      begin
        assetsfile := assetsfile.Substring(0, Pos('?', assetsfile));
      end;
      try
        try
          extension := ExtractFileExt(assetsfile).Replace('.', '');
          assets.LoadFromFile(assetsfile);
          _Response.ContentType := getMimeType(extension);
          if _Response.ContentType <> '' then
          begin
            _Response.SendStream(assets);
            _Response.SendResponse;
          end
          else
          begin
            Error404(_Response, url);
          end;
        except
          Error404(_Response, url);
        end;
      finally
        assets.Free;
      end;
    end
    else
    begin
      Error404(_Response, url);
    end;
  end;
end;

function getMimeType(extension: string): string;
var
  MimeType: string;
begin
  MonitorEnter(_mime);
  try
    if _mime.TryGetValue(extension, MimeType) then
      Result := MimeType + '; charset=' + Config.document_charset
    else
      Result := '';
  finally
    MonitorExit(_mime);
  end;
end;

procedure Error404(Response: TWebResponse; url: string);
var
  s: string;
  page: Tpage;
begin
  Response.StatusCode := 404;
  Response.ContentType := 'text/html; charset=' + Config.document_charset;
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
  Response.Content := s;
  Response.SendResponse;
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
      f.LoadFromFile(WebApplicationDirectory + Config.config, TEncoding.UTF8);
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
  Extensions, MimeType: string;
  json, jo: ISuperObject;
  ja: ISuperArray;
  i, j: integer;
  txt: string;
  sp: TStringList;
begin
  f := TStringList.Create;
  try
    try
      f.LoadFromFile(WebApplicationDirectory + Config.mime);
      txt := f.Text.Trim;
      json := SO(txt);
      if json.DataType = TDataType.dtArray then
      begin
        ja := json.AsArray;
        for i := 0 to ja.Length - 1 do
        begin

          try
            jo := ja.O[i];
            Extensions := jo.s['Extensions'];
            MimeType := jo.s['MimeType'];
            sp := TStringList.Create;
            try
              sp.Delimiter := ';';
              sp.DelimitedText := Extensions;
              for j := 0 to sp.Count - 1 do
              begin
                if trim(sp[j]) <> '' then
                  _mime.AddOrSetValue(sp[j], MimeType);
              end;
            finally
              sp.Free;
            end;
          except
            log('MIME配置文件错误,服务启动失败');
            break;
          end;
        end;
      end;
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


  //////////////////////////////////////////////////////////
  InitApplication; //启动服务
 // if WebRequestHandler <> nil then
 //   WebRequestHandler.WebModuleClass := WebModuleClass;
  ////////////////////顺序不可更换//////////////////////////
  AppOpen := True;
  _LogList := TStringList.Create;
  _logThread := TLogTh.Create(false);
  _mime := TDictionary<string, string>.Create;
  _directory_permission := TDictionary<string, Boolean>.Create;
  FPort := '0000';
  try
    try
      _MIMEConfig := OpenMIMEFile.AsJSON();
      jo := _ConfigJSON;
      if jo <> nil then
      begin
        SetConfig(jo);
        FPort := jo.O['Server'].s['Port'];
      //////////////////////////////////////////
        syn_Port := FPort;
        syn_Compress := jo.O['Server'].s['Compress'];
        syn_HTTPQueueLength := jo.O['Server'].i['HTTPQueueLength'];
        syn_ChildThreadCount := jo.O['Server'].i['ChildThreadCount'];
        ////////////////////////////////////////////////////
        _SessionName := Config.session_name;
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
        JWT_Init; //JWT模块初始化
        if Config.open_package then
          _PackageManager := TPackageManager.Create;
        CreateRouteMap();
        _SessionListMap := TSessionList.Create;

        _Interceptor := TInterceptor.Create;
        _PageCache := TPageCache.Create;
        _DBPoolList := TDBPoolList.Create;
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
  _directory_permission.Clear;
  _directory_permission.Free;
  _mime.Free;
  if _logThread <> nil then
  begin
    _logThread.Terminate;
  end;
  if _SessionListMap <> nil then
  begin
    _SessionListMap.Terminate;
  end;
  if Config.open_package and (_PackageManager <> nil) then
  begin
    _PackageManager.isstop := true;
  end;
  if _DBPoolList <> nil then
    _DBPoolList.Terminate;

  Sleep(200);

  if _logThread <> nil then
  begin
    _logThread.Free;
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
  if _SessionListMap <> nil then
    _SessionListMap.Free;

  if MVCDM <> nil then
    MVCDM.Free;
  if _RedisList <> nil then
    _RedisList.Free;
  if Global <> nil then
    Global.Free;
  if _PageCache <> nil then
    _PageCache.Free;
  if _DBPoolList <> nil then
    _DBPoolList.Free;
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

procedure TMVCFun.showpagelist();
var
  index, i: Integer;
  key: string;
begin
  for key in _PageCache.PageList.Keys do
  begin
    if PageList.IndexOf(key) < 0 then
      PageList.Add(key);
  end;
  PageList.Sorted := true;
  for i := 0 to PageList.Count - 1 do
  begin
    Writeln(i, ': ', PageList.Strings[i]);
  end;
  if PageList.Count = 0 then
    Writeln('PageCache is NULL');
end;

procedure TMVCFun.Run(title: string);
var
  hMutex: THandle;
  appTitle: string;
begin
  appTitle := '';
  if config.config = '' then
    Config.config := 'resources/config.json';
  if config.mime = '' then
    Config.mime := 'resources/mime.json';
  if config.package_config = '' then
    Config.package_config := 'resources/package.json';
  //////////////////////////////////////////////////
  _ConfigJSON := OpenConfigFile();
  if _ConfigJSON <> nil then
  begin
    if (_ConfigJSON['AppTitle'] <> nil) and (_ConfigJSON['AppTitle'].AsString <> '') then
    begin
      appTitle := _ConfigJSON['AppTitle'].AsString;
    end;
  end;
  if appTitle <> '' then
    title := appTitle;
  if (appTitle = '') and (title = '') then
    title := ExtractFileName(Application.ExeName).Replace('.exe', '');
  //////////////////////////
  ReportMemoryLeaksOnShutdown := True;
	{$IFDEF CONSOLE}
  {$IFDEF MSWINDOWS}
  SetConsoleTitle(PChar(title));
  {$ENDIF}
  Writeln('Project:' + title);
  StartServer();
  while True do
  begin
    if not _MVCFun.RunCommand() then
      Break;
  end;
  CloseServer();
  {$ELSE}
	{$IFDEF MSWINDOWS}

  Application.Initialize;
  Application.Title := title;
  hMutex := CreateMutex(nil, false, PChar(title));
  try
    if GetLastError = Error_Already_Exists then
    begin
      Application.MessageBox(PChar(title + '已经启动'), '提示', MB_OK + MB_ICONINFORMATION + MB_DEFBUTTON2);
    end
    else
    begin
      if not Assigned(MVCMain) then
      begin
        Application.CreateForm(TMVCMain, MVCMain);
        Application.Run;
      end;
    end;
  finally
    ReleaseMutex(hMutex);
  end;
  {$ENDIF}
  {$ENDIF}
end;

constructor TMVCFun.Create;
begin
  PageList := TStringList.Create;
end;

destructor TMVCFun.Destroy;
begin
  PageList.Clear;
  PageList.Free;
  inherited;
end;

function TMVCFun.RunCommand(): Boolean;
var
  LResponse: string;
  index, i: Integer;
  key: string;
begin
  if not isShow then
  begin
    Writeln('''Stop'' Close Server');
    Writeln('''ShowPage'' Show PageCatch');
    Writeln('''Removekey key'' Remove PageCatch');
    Writeln('''RemoveAll'' Remove All PageCatch');
    isShow := true;
  end;
  readln(LResponse);
  Result := true;
  if LResponse.ToLower = 'stop' then
    Result := False;
  if LResponse.ToLower = 'removeall' then
  begin
    _PageCache.PageList.Clear;
    PageList.Clear;
    showpagelist();
  end;
  if LeftStr(LResponse.ToLower, 9) = 'removekey' then
  begin
    try
      index := LResponse.ToLower.Replace('removekey', '').Trim().ToInteger;
      key := PageList.Strings[index];
      _PageCache.PageList.Remove(key);
      PageList.Delete(index);
      showpagelist();
    except
      Writeln('Input Error');
    end;
  end;
  if LResponse.ToLower = 'showpage' then
  begin
    showpagelist();
  end;
end;

initialization
  _MVCFun := TMVCFun.Create;
  CreateRouteMap;

finalization
  _MVCFun.Free;
  if Assigned(_RouteMap) then
    _RouteMap.Free;

end.

