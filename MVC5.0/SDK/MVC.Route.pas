
{*******************************************************}
{                                                       }
{       DelphiWebMVC 5.0                                }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2022-2 苏兴迎(PRSoft)              }
{                                                       }
{*******************************************************}
unit MVC.Route;

interface

uses
  System.SysUtils, System.DateUtils, System.Classes, System.StrUtils,
  System.Generics.Collections, system.TypInfo, System.Rtti, MVC.Config, HTTPApp,
  IdURI, SynCommons, MVC.Controller, MVC.LogUnit, MVC.TplUnit, MVC.Tool;

type
  TRouteItem = class
  private
    MethodList: TStringList;
    HttpMethod: TStringList;
    locMethodList: TStringList;
    FPath: string;
    FName: string;
    FAction: TClass;

    procedure SetAction(const Value: TClass);
    procedure SetName(const Value: string);
    procedure SetPath(const Value: string);
  public
    ActoinClass: TRttiType;
    CreateController, Intercept, Show: TRttiMethod;
    Response, Request, routeUrl_pro, tplPath_pro: TRttiProperty;
    property routeUrl: string read FName write SetName;
    property Action: TClass read FAction write SetAction;
    property tplPath: string read FPath write SetPath;
    function ActionMethod(methodname: string): TRttiMethod;
    function getMethod(methodname: string): string;
    function getMethodTpl(methodname: string): string;
    function getMethodType(methodname: string): string;
    constructor Create();
    destructor Destroy; override;
  end;

  TRoute = class
  private
    _RTTIContext: TRttiContext;
    list: TObjectList<TRouteItem>;
    listkey: TStringList;
    function GetItem(Route: string): TRouteItem;
    function finditem(name: string): Boolean;
    function DateTimeToGMT(const ADate: TDateTime): string;
    procedure loadAssets(_Request: TWebRequest; _Response: TWebResponse; url: string);
    function getMimeType(extension: string): string;
    function StrToParamTypeValue(AValue: string; AParamType: System.TTypeKind): TValue;

  public
    procedure SetRoute(routeUrl: string; Action: TClass; tplPath: string; rqUrl: string; locUrl: string; httpMethod: string);
    function GetRoute(url: string; var Route: string; var method: string): TRouteItem;
    procedure Error500(Response: TWebResponse; msg: string = '');
    procedure Error404(Response: TWebResponse; msg: string);
    function GetUrlParams(methodname: string; url: string; Request: TWebRequest; Response: TWebResponse; item: TRouteItem; ActionMethod: TRttiMethod): TArray<TValue>;
    constructor Create(); virtual;
    destructor Destroy; override;
  end;

var
  RouteMap: TRoute;

procedure initRoute;

procedure OpenRoute(_Request: TWebRequest; _Response: TWebResponse);

implementation
{ TRoute }

procedure initRoute;
var
  ms: TArray<TRttiMethod>;
  tts: TArray<TRttiType>;
  tmpMethod: TRttiMethod;
  lMethod, sRouteUrl, mRouteUrl, sTplPath, s, sHttpMethod: string;
  tt: TRttiType;
  cl: TClass;
  _RTTIContext: TRttiContext;
  AttrMethod, AttrClass: TCustomAttribute;
begin
  tts := _RTTIContext.GetTypes;
  for tt in tts do
  begin
    begin
      if (tt.Handle.Kind = System.TTypeKind.tkClass) then
      begin

        cl := tt.Handle.TypeData.ClassType;

        if (cl.InheritsFrom(TController)) then
        begin
          s := cl.ClassName;
          for AttrClass in tt.GetAttributes do
          begin
            if AttrClass is TMURL then
            begin
              with TMURL(AttrClass) do
              begin
                sRouteUrl := routeUrl;
                sTplPath := tplPath;
                RouteMap.setRoute(sRouteUrl, cl, sTplPath, '', '', '');
              end;
            end;
          end;
          ms := tt.GetMethods;

          for tmpMethod in ms do
          begin
            for AttrMethod in tmpMethod.GetAttributes do
            begin
              if AttrMethod is TMURL then
              begin
                with TMURL(AttrMethod) do
                begin
                  mRouteUrl := routeUrl;
                  lMethod := tmpMethod.Name;
                  sHttpMethod := getMethodType;
                  RouteMap.setRoute(sRouteUrl, cl, sTplPath, mRouteUrl, lMethod, sHttpMethod);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function LoadFile(_Response: TWebResponse; url: string): boolean;
var
  filepath: string;
  page: TPage;
begin
  filepath := Config.BasePath + Config.WebRoot + '\' + Config.template + url + Config.template_type;
  page := Tpage.Create(filepath);
  try
    if page.Text() <> '' then
    begin
      _Response.ContentType := 'text/html; charset=' + Config.document_charset;
      _Response.Content := page.Text();
      _Response.SendResponse;
      Result := true;
    end
    else
    begin
      Result := false;
    end;
  finally
    page.Free;
  end;
end;

procedure OpenRoute(_Request: TWebRequest; _Response: TWebResponse);
var
  Action: TObject;
 // Attribute: TCustomAttribute;
  ActionMethod, Intercept, CreateControllerMethod, Show: TRttiMethod;
  Response, Request, tplPath, RouteUrl: TRttiProperty;
  url, RoutePath, assetsfile: string;
  item: TRouteItem;
  k: Integer;
  methodname, httpMethod: string;
  ret_Intercept: TValue;
  InterceptRet: boolean;
  aValueArray: TArray<TValue>;
begin
  InterceptRet := false;
  _Response.ContentEncoding := Config.document_charset;
  _Response.Date := Now;
  httpMethod := _Request.Method;
  url := _Request.PathInfo;
  //
  url := IITool.UrlFmt(url);
  if Config.App <> '' then
  begin
    url := url.Replace(Config.App, '');
  end;
  assetsfile := Config.BasePath + Config.WebRoot + url;
  assetsfile := IITool.PathFmt(assetsfile);
  if (Config.suffix.Trim <> '') and (not FileExists(assetsfile)) then
  begin
    if RightStr(url, Length(Config.suffix)) = Config.suffix then
      url := url.Replace(Config.suffix, '');
  end;
  if not Config.check_directory_permission(url) then
  begin
    RouteMap.Error404(_Response, url);
    exit;
  end;
  k := Pos('.', url);
  if k <= 0 then
  begin
    item := RouteMap.GetRoute(url, RoutePath, methodname);
    if item <> nil then
    begin
      Action := item.Action.Create;
      try
        Show := item.Show;
        Request := item.Request;
        Response := item.Response;
        tplPath := item.tplPath_pro;
        RouteUrl := item.routeUrl_pro;
        Intercept := item.Intercept;   //获取拦截方法
        CreateControllerMethod := item.CreateController;

        Request.SetValue(Action, _Request);
        Response.SetValue(Action, _Response);
        tplPath.SetValue(Action, item.tplPath);
        RouteUrl.SetValue(Action, item.RouteUrl);

        try
          CreateControllerMethod.Invoke(Action, []); //控制器创建触发动作
        except
          on E: Exception do
          begin
            Log('控制器异常:' + e.Message);
            RouteMap.Error500(_Response);
            exit;
          end;
        end;
        try
          ret_Intercept := Intercept.Invoke(Action, []); //拦截器执行
          InterceptRet := ret_Intercept.AsBoolean;
        except
          on E: Exception do
          begin
            Log('拦截器异常:' + e.Message);
            RouteMap.Error500(_Response);
            exit;
          end;
        end;

        if (url.IndexOf('//') > -1) then
        begin
          url := url.Replace('//', '/');
          _Response.SendRedirect(url);
          _Response.SendResponse;
          exit;
        end;

        methodname := item.getMethod(methodname);
        if methodname = '' then
        begin
          if url[url.Length] = '/' then
            url := url + 'index';
          RouteMap.Error404(_Response, url);
          exit;
        end;
        if (item.getMethodType(methodname) <> '')
          and (httpMethod.ToUpper <> item.getMethodType(methodname)

          ) then
        begin
          RouteMap.Error404(_Response, url);
          exit;
        end;
        ActionMethod := item.ActionMethod(methodname);
        if ActionMethod <> nil then
        begin
          try

            aValueArray := RouteMap.GetUrlParams(methodname, url, _Request, _Response, item, ActionMethod);

            if not InterceptRet then
            begin
              if length(aValueArray) > 0 then
                ActionMethod.Invoke(Action, aValueArray)
              else
                ActionMethod.Invoke(Action, []);
              if _Response.ContentType = '' then
                Show.Invoke(Action, [methodname]);
              _Response.SendResponse;
            end
            else
            begin
              if _Response.StatusCode = 302 then
                _Response.SendResponse
              else
                RouteMap.Error404(_Response, url);
            end;
          except
            RouteMap.Error500(_Response);
          end;
        end
        else
        begin
          if not InterceptRet then
          begin
            if not LoadFile(_Response, url) then
              RouteMap.Error404(_Response, url);
          end
          else
          begin
            RouteMap.Error404(_Response, url);
          end;
        end;
      finally
        Action.Free;
      end;
    end
    else
    begin
      if not InterceptRet then
      begin
        if not LoadFile(_Response, url) then
          RouteMap.Error404(_Response, url);
      end
      else
      begin
        RouteMap.Error404(_Response, url);
      end;
    end;
  end
  else
  begin
    RouteMap.loadAssets(_Request, _Response, url); //加载资源文件
  end;
end;

constructor TRoute.Create;
begin
  list := TObjectList<TRouteItem>.Create;
  listkey := TStringList.Create;
end;

function TRoute.DateTimeToGMT(const ADate: TDateTime): string;
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

destructor TRoute.Destroy;
begin
  listkey.Clear;
  listkey.Free;
  list.Clear;
  list.Free;
end;

procedure TRoute.Error500(Response: TWebResponse; msg: string);
var
  Content, tplFile: string;
  page: Tpage;
begin
  if msg = '' then
    msg := '系统异常,请查看日志';
  Content := '<html><body><div style="text-align: left;">';
  Content := Content + '<div><h1>Error 500</h1></div>';
  Content := Content + '<hr><div>[ ' + msg + ' ]' + '</div></div></body></html>';
  if Trim(Config.Error500) <> '' then
  begin
    tplFile := Config.BasePath + config.WebRoot + '\' + Config.Error500 + '.html';
    if FileExists(tplFile) then
    begin
      page := Tpage.Create(tplFile);
      try
        Content := page.Text('<div>[ ' + msg + ' ]' + '</div>');
      finally
        page.Free;
      end;
    end;
  end;
  Response.StatusCode := 500;
  Response.ContentType := 'text/html; charset=' + Config.document_charset;
  Response.Content := Content;
  Response.SendResponse;
end;

procedure TRoute.Error404(Response: TWebResponse; msg: string);
var
  Content, tplFile: string;
  page: Tpage;
begin

  Content := '<html><body><div style="text-align: left;">';
  Content := Content + '<div><h1>Error 404</h1></div>';
  Content := Content + '<hr><div>[ ' + msg + ' ] Not Find Page' + '</div></div></body></html>';
  if Trim(Config.Error404) <> '' then
  begin
    tplFile := Config.BasePath + config.WebRoot + '\' + Config.Error404 + '.html';
    if FileExists(tplFile) then
    begin
      page := Tpage.Create(tplFile);
      try
        Content := page.Text('<div>[ ' + msg + ' ] Not Find Page' + '</div>');
      finally
        page.Free;
      end;
    end;
  end;
  Response.StatusCode := 404;
  Response.ContentType := 'text/html; charset=' + Config.document_charset;
  Response.Content := Content;
  Response.SendResponse;
end;

function TRoute.finditem(name: string): Boolean;
var
  j: integer;
  key: string;
begin
  Result := false;
  for j := 0 to listkey.Count - 1 do
  begin
    key := listkey.Strings[j];
    if UpperCase(key) = UpperCase(name) then
    begin
      Result := true;
      break;
    end;
  end;
end;

function TRoute.GetItem(Route: string): TRouteItem;
var
  I, j: Integer;
  item, defitem: TRouteItem;
  key: string;
  isFind: Boolean;
begin
  Result := nil;
  defitem := nil;
  isFind := false;
  for j := 0 to listkey.Count - 1 do
  begin
    key := listkey.Strings[j];
    if (UpperCase(key) = LeftStr(UpperCase(Route), Length(key))) or (UpperCase(key) = LeftStr(UpperCase(Route + '/'), Length(key))) then
    begin
      isFind := true;
      break;
    end;
  end;
  if isFind then
  begin
    for I := 0 to list.Count - 1 do
    begin
      item := list.Items[I];
      if ((key = item.routeUrl) or ((key + '/') = item.routeUrl)) and (Length(item.routeUrl) > 1) then
      begin
        Result := item;
        break;
      end
      else if ((key = item.routeUrl) or ((key + '/') = item.routeUrl)) and (item.routeUrl = '/') then
      begin
        defitem := item;
      end;
    end;
  end;
  if Result = nil then
    Result := defitem;
end;

function TRoute.GetRoute(url: string; var Route: string; var method: string): TRouteItem;
var
  item: TRouteItem;
  url1: string;
  tmp: string;
begin
  url1 := Trim(url);
  item := GetItem(url1);
  if item <> nil then
  begin
    Route := url1;
    tmp := Copy(Route, Length(item.routeUrl) + 1, Length(Route) - Length(item.routeUrl));
    method := Copy(tmp, 1, Pos('/', tmp) - 1);
    if method = '' then
    begin
      if tmp <> '' then
        method := tmp
      else
        method := 'index';
    end;
  end;
  Result := item;
end;

function TRoute.StrToParamTypeValue(AValue: string; AParamType: System.TTypeKind): TValue;
begin
  case AParamType of
    System.TTypeKind.tkInteger, System.TTypeKind.tkInt64:
      begin
        try
          if AValue.Trim = '' then
            AValue := '0';
          Result := StrToInt(AValue);
        except
          Result := 0;
        end;
      end;
    System.TTypeKind.tkFloat:
      begin
        try
          if AValue.Trim = '' then
            AValue := '0';
          Result := StrToFloat(AValue);
        except
          Result := 0;
        end;
      end;
    System.TTypeKind.tkString, System.TTypeKind.tkChar, System.TTypeKind.tkWChar, System.TTypeKind.tkLString, System.TTypeKind.tkWString, System.TTypeKind.tkUString, System.TTypeKind.tkVariant:
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

function TRoute.GetUrlParams(methodname: string; url: string; Request: TWebRequest; Response: TWebResponse; item: TRouteItem; ActionMethod: TRttiMethod): TArray<TValue>;
var
  //--------大量提供begin------------
  i: integer;
  ActionMethonValue: TRttiParameter;
  ActionMethonValues: TArray<TRttiParameter>;
  aValueArray: TArray<TValue>;
  sParameters: string;
  sValue, s, s1: string;
  params, paramTpl, paramSet: TStringList;
  //-------大量提供end--------------
begin
  ActionMethonValues := ActionMethod.GetParameters;

  SetLength(aValueArray, Length(ActionMethonValues));
  if Length(item.routeUrl + methodname) = Length(url) then
  begin
    for i := Low(ActionMethonValues) to High(ActionMethonValues) do
    begin
      ActionMethonValue := ActionMethonValues[i];
      sParameters := ActionMethonValue.Name;   //参数名
      if Request.MethodType = mtGet then  //从web.GET中提取值
        sValue := Request.QueryFields.Values[sParameters]
      else
      begin
        sValue := Request.ContentFields.Values[sParameters]; //从web.POST中提取值
        if sValue = '' then
          sValue := Request.QueryFields.Values[sParameters];
      end;
      aValueArray[i] := StrToParamTypeValue(sValue, ActionMethonValue.ParamType.TypeKind); //根据参数数据类型，转换值，只传常量
    end;
  end
  else
  begin
    params := TStringList.Create;
    paramTpl := TStringList.Create;
    paramSet := TStringList.Create;
    try
      s1 := item.routeUrl;
      s := Copy(url, Length(s1) + 1, Length(url) - Length(s1));
      params.Delimiter := '/';
      params.DelimitedText := s;
      paramTpl.Delimiter := '/';
      paramTpl.DelimitedText := item.getMethodTpl(methodname);
      for i := Low(ActionMethonValues) to High(ActionMethonValues) do
      begin
        if (i < params.Count - 1) then
        begin
          sValue := params.Strings[i + 1];
          paramSet.Values[paramTpl.Strings[i + 1]] := sValue;
        end;
      end;
      for i := Low(ActionMethonValues) to High(ActionMethonValues) do
      begin
        ActionMethonValue := ActionMethonValues[i];
        sValue := paramSet.Values[':' + ActionMethonValue.Name];
        aValueArray[i] := StrToParamTypeValue(sValue, ActionMethonValue.ParamType.TypeKind); //根据参数数据类型，转换值，只传常量
      end;
    finally
      paramSet.Clear;
      params.Clear;
      paramTpl.Clear;
      paramSet.Free;
      params.Free;
      paramTpl.Free;
    end;
  end;
  Result := aValueArray;
end;

function TRoute.getMimeType(extension: string): string;
var
  MimeType, key: string;
begin
  Lock(Config.MIME);
  try
    Result := '';
    for key in Config.MIME.Keys do
    begin
      if (Pos(extension, key) > 0) and (Config.MIME.TryGetValue(key, MimeType)) then
      begin
        Result := MimeType + '; charset=' + Config.document_charset;
        Break;
      end;
    end;
  finally
    UnLock(Config.MIME);
  end;
end;

procedure TRoute.loadAssets(_Request: TWebRequest; _Response: TWebResponse; url: string);
var
  tmp, assetsfile, extension, webpath: string;
  assets: TMemoryStream;
begin
  if (not Config.open_debug) and Config.open_cache then
  begin
    _Response.SetCustomHeader('Cache-Control', 'max-age=' + Config.cache_max_age);
    _Response.SetCustomHeader('Pragma', 'Pragma');
    //TTimeZone.local.ToUniversalTime(now())
    tmp := DateTimeToGMT(now);
    _Response.SetCustomHeader('Last-Modified', tmp);
    tmp := DateTimeToGMT(IncHour(now(), 24));
    _Response.SetCustomHeader('Expires', tmp);
  end
  else
  begin
    _Response.SetCustomHeader('Cache-Control', 'no-cache,no-store');
  end;
  webpath := Config.BasePath;
  assetsfile := webpath + Config.WebRoot + url;
  if FileExists(assetsfile) then
  begin
    if Pos('?', assetsfile) > 0 then
    begin
      assetsfile := assetsfile.Substring(0, Pos('?', assetsfile));
    end;
    assets := TMemoryStream.Create;
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

function DescCompareStrings(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := -AnsiCompareText(List[Index1], List[Index2]);
end;

procedure TRoute.SetRoute(routeUrl: string; Action: TClass; tplPath: string; rqUrl: string; locUrl: string; httpMethod: string);
var
  item: TRouteItem;
  SrqUrl: string;
begin
 // s := Action.ClassName;
  if (routeUrl.Trim <> '') and (routeUrl.Trim <> '/') then
    routeUrl := '/' + routeUrl + '/'
  else
    routeUrl := '/';
  if Config.App.Trim <> '' then
  begin
    routeUrl := '/' + Config.App + routeUrl;
  end;
  routeUrl := routeUrl.Replace('///', '/').Replace('//', '/');

  if not finditem(routeUrl) then
  begin

    item := TRouteItem.Create;
    item.Action := Action;
    item.tplPath := tplPath;
    item.routeUrl := routeUrl;

    item.ActoinClass := _RTTIContext.GetType(item.Action);
    with item do
    begin
      Show := ActoinClass.GetMethod('Show');
      CreateController := ActoinClass.GetMethod('CreateController');
      Intercept := ActoinClass.GetMethod('Intercept');
      Request := ActoinClass.GetProperty('Request');
      Response := ActoinClass.GetProperty('Response');
      routeUrl_pro := ActoinClass.GetProperty('routeUrl');
      tplPath_pro := ActoinClass.GetProperty('tplPath');
    end;
    List.Add(item);
    listkey.Add(routeUrl);
    listkey.CustomSort(DescCompareStrings);
  end
  else
  begin
    if Pos(':', rqUrl) > 0 then
      SrqUrl := rqUrl.Substring(0, Pos(':', rqUrl) - 2)
    else
      SrqUrl := rqUrl;
    item := GetItem(routeUrl);
    item.MethodList.Values[SrqUrl] := locUrl;
    item.locMethodList.Values[locUrl] := rqUrl;
    item.HttpMethod.Values[SrqUrl] := httpMethod;
  end;
end;
{ TRouteItem }

function TRouteItem.ActionMethod(methodname: string): TRttiMethod;
begin
  result := ActoinClass.GetMethod(methodname);
end;

constructor TRouteItem.Create();
begin
  MethodList := TStringList.Create;
  locMethodList := TStringList.Create;
  httpMethod := TStringList.Create;
end;

destructor TRouteItem.Destroy;
begin
  httpMethod.Free;
  MethodList.Free;
  locMethodList.Free;
  inherited;
end;

function TRouteItem.getMethod(methodname: string): string;
var
  met: string;
begin
  met := MethodList.Values[methodname];
  if met <> '' then
    Result := met
  else
  begin
    met := locMethodList.Values[methodname];
    if met <> '' then
      Result := ''
    else
      Result := methodname;
  end;
end;

function TRouteItem.getMethodTpl(methodname: string): string;
var
  svalue: string;
begin
  Result := '';
  svalue := MethodList.Values[methodname];
  if svalue <> '' then
  begin
    result := locMethodList.Values[svalue];
  end;
end;

function TRouteItem.getMethodType(methodname: string): string;
begin
  result := httpMethod.Values[methodname].ToUpper;
end;

procedure TRouteItem.SetAction(const Value: TClass);
begin
  FAction := Value;
end;

procedure TRouteItem.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TRouteItem.SetPath(const Value: string);
begin
  FPath := Value;
end;

initialization
  RouteMap := TRoute.Create;

finalization
  RouteMap.Free;

end.

