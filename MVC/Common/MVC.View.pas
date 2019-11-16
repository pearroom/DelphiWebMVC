{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.View;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, FireDAC.Comp.Client, MVC.Page,
  XSuperObject, MVC.Config, Data.DB, MVC.HTMLParser, uDBConfig, uPlugin,
  MVC.RedisM, MVC.RedisList, MVC.PageCache, MVC.DBPoolList,
  System.RegularExpressions;

type
  TView = class(TPersistent)
  private
    RedisM: TRedisM;
    RedisItem: TRedisItem;
    ActionP: string;
    ActionR: string;
    sessionid: string;
    htmlpars: THTMLParser;
    url: string; // 当前模板路径
    params: TStringList;
    procedure CreateSession(); // 创建获取session
    procedure makeSession;
  public
    DbItem: TDbItem;
    Db: TDBConfig;
    Plugin: TPlugin;
    Response: TWebResponse;
    Request: TWebRequest;
    procedure FreeDb;
    function JsonToString(json: string): string;
    function GetGUID: string;
    function Q(str: string): string;
    function RedisRemove(key: string): Boolean;
    procedure RedisSetKeyText(key: string; value: string; timerout: Integer = 0);
    function RedisGetKeyText(key: string): string;
    procedure RedisSetKeyJSON(key: string; value: ISuperObject; timerout: Integer = 0);
    function RedisGetKeyJSON(key: string): ISuperObject;
    function RedisGetKeyCount: Integer;
    procedure RedisSetExpire(key: string; timerout: Integer);
    procedure SessionSet(key, value: string);   // session控制 value传入json字符串作为对象存储
    procedure SessionSetJSON(key: string; json: ISuperObject);
    function SessionGet(key: string): string;   // session 值获取
    function SessionGetJSON(key: string): ISuperObject;   // session 值获取
    function SessionRemove(key: string): Boolean;
    function SessionDestroy: Boolean;           //释放session 将销毁本次会话
    function SessionCount: integer;        //获取session数量
    function Cookies(): TCookie;                // cookies 操作
    function CookiesValue(key: string): string; // cookies 操作
    procedure CookiesSet(key, value: string);   // cookies 操作
    function Input(param: string): string;      // 返回参数值，get post
    function InputInt(param: string): Integer;      // 返回参数值，get post
    function InputToJSON(): ISuperObject;          //返回参数的json结构
    function InputByIndex(index: Integer): string;
    procedure setAttr(key, value: string);      // 设置视图标记显示内容 ，如果 value是 json 数组可以在 table 标记中显示
    procedure setAttrJSON(key: string; json: ISuperObject);
    procedure ShowHTML(html: string);           // 显示模板
    procedure ShowText(text: string);           // 显示文本，json格式需转换后显示
    procedure ShowJSON(jo: ISuperObject); overload;       // 显示 json
    procedure ShowJSON(json: string); overload;       // 显示 json
    procedure ShowJSON(cds: TFDQuery); overload;       // 显示 json
    procedure ShowXML(xml: string);        // 显示 xml 数据
    procedure ShowPage(count: Integer; data: ISuperObject); overload;   //渲染分页数据
    procedure ShowPage(count: Integer; jsondata: string); overload;   //渲染分页数据
    procedure Redirect(action: string; path: string = '');        // 跳转 action 路由,path 路径
    procedure Success(code: Integer = 0; msg: string = '');
    procedure Fail(code: Integer = -1; msg: string = '');
    function CDSToJSONText(cds: TFDQuery): string;
    procedure setData(Response_: TWebResponse; Request_: TWebRequest; ActionPath, ActionRoule: string);
    constructor Create(Response_: TWebResponse; Request_: TWebRequest; ActionPath, ActionRoule: string);
    destructor Destroy; override;
  end;

implementation

uses
  MVC.SessionList, MVC.command, MVC.LogUnit;

{ TView }
function TView.JsonToString(json: string): string;
var
  index: Integer;
  temp, top, last: string;
begin
  index := json.IndexOf('\u');
  if index < 0 then
  begin
    last := json;
    Result := last;
    Exit;
  end;
  index := 1;
  while index >= 0 do
  begin
    index := json.IndexOf('\u');
    if index < 0 then
    begin
      last := json;
      Result := Result + last;
      Exit;
    end;
    top := Copy(json, 1, index); //取出 编码字符前的 非 unic 编码的字符，如数字
    temp := Copy(json, index + 1, 6); //取出编码，包括 \u    ,如\u4e3f
    Delete(temp, 1, 2);
    Delete(json, 1, index + 6);
    result := Result + top + WideChar(StrToInt('$' + temp));
  end;
end;

function TView.CDSToJSONText(cds: TFDQuery): string;
var
  i: Integer;
  ret: string;
  ftype: TFieldType;
  json, item, key, value: string;
begin
  ret := '';

  json := '[';
  with cds do
  begin
    First;

    while not Eof do
    begin
      item := '{';
      for i := 0 to Fields.Count - 1 do
      begin
        if Config.JsonToLower then
          key := Fields[i].DisplayLabel.ToLower
        else
          key := Fields[i].DisplayLabel;
        ftype := Fields[i].DataType;
        if (ftype = ftAutoInc) then
          value := Fields[i].AsString
        else if (ftype = ftInteger) then
          value := Fields[i].AsString
        else if (ftype = ftBoolean) then
          value := Fields[i].AsString
        else
        begin
          value := '"' + Fields[i].AsString + '"';
        end;
        if value = '' then
          value := '0';
        item := item + '"' + key + '"' + ':' + value + ',';
      end;
      item := copy(item, 1, item.Length - 1);
      item := item + '},';
      json := json + item;
      Next;
    end;
  end;
  if json.Length > 1 then
    json := copy(json, 1, json.Length - 1);
  json := json + ']';
  Result := json;
end;

function TView.RedisGetKeyCount: Integer;
begin
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    Result := RedisM.getKeyCount
  else
    Result := -1;
end;

function TView.RedisGetKeyJSON(key: string): ISuperObject;
begin
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    Result := RedisM.getKeyJSON(key)
  else
    Result := nil;
end;

function TView.RedisGetKeyText(key: string): string;
begin
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    Result := RedisM.getKeyText(key)
  else
    Result := '';
end;

function TView.RedisRemove(key: string): Boolean;
begin
  Result := false;
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    Result := RedisM.delKey(key);
end;

procedure TView.RedisSetExpire(key: string; timerout: Integer);
begin
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    RedisM.setExpire(key, timerout);
end;

procedure TView.RedisSetKeyJSON(key: string; value: ISuperObject; timerout: Integer);
begin
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    RedisM.setKeyJSON(key, value, timerout);
end;

procedure TView.RedisSetKeyText(key, value: string; timerout: Integer);
begin
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    RedisM.setKeyText(key, value, timerout);
end;

procedure TView.setAttr(key, value: string);
begin
  params.Values[key] := value;
end;

procedure TView.setAttrJSON(key: string; json: ISuperObject);
begin
  if json <> nil then
    setAttr(key, (json.AsJSON()));
end;

procedure TView.setData(Response_: TWebResponse; Request_: TWebRequest; ActionPath, ActionRoule: string);
var
  webroot: string;
begin
  DbItem := getDbFromPool;
  Db := DbItem.Db;
  htmlpars.Db := Db;
  self.ActionP := ActionPath;
  self.ActionR := ActionRoule;
  if (Trim(self.ActionP) <> '') then
  begin
    {$IFDEF MSWINDOWS}
    self.ActionP := self.ActionP + '\';
    {$ELSE}
    self.ActionP := self.ActionP + '/';
    {$ENDIF}
  end;
  {$IFDEF MSWINDOWS}
  if Config.__WebRoot__.Trim <> '' then
    webroot := Config.__WebRoot__ + '\';
  url := WebApplicationDirectory + webroot + Config.template + '\' + self.ActionP;
  {$ELSE}
  if Config.__WebRoot__.Trim <> '' then
    webroot := Config.__WebRoot__ + '/';
  url := WebApplicationDirectory + webroot + Config.template + '/' + self.ActionP;
  {$ENDIF}
  self.Response := Response_;
  self.Request := Request_;

  if (Config.session_start) then
    CreateSession();
end;

procedure TView.ShowText(text: string);
begin

  Response.ContentType := 'text/html; charset=' + Config.document_charset;
  Response.Content := text;
  Response.SendResponse;
end;

procedure TView.ShowXML(xml: string);
begin
  Response.ContentType := 'application/xml; charset=' + Config.document_charset;
  Response.Content := xml;
  Response.SendResponse;
end;

procedure TView.Success(code: Integer; msg: string);
var
  jo: ISuperObject;
begin
  jo := SO();

  jo.I['code'] := code;
  if Trim(msg) = '' then
    msg := '操作成功';
  jo.S['message'] := msg;
  ShowJSON(jo);
end;

procedure TView.ShowHTML(html: string);
var
  p: string;
  S: string;
  page: TPage;
  htmlcontent: string;
begin
  p := '';
  Response.Content := '';
  Response.ContentType := 'text/html; charset=' + Config.document_charset;
  if (Trim(html) <> '') then
  begin
    S := url + html + Config.template_type;
    if _PageCache.PageList.ContainsKey(S) then
    begin
      _PageCache.PageList.TryGetValue(S, htmlcontent);
      htmlpars.Parser(htmlcontent, params, self.url);
      Response.Content := htmlcontent;
    end
    else
    begin
      if (not FileExists(S)) then
      begin
        Response.StatusCode := 404;
        if Trim(Config.Error404) <> '' then
        begin
          page := TPage.Create(Config.Error404, nil, '');
          try
            S := page.HTML;
          finally
            page.Free;
          end;
        end
        else
        begin
          S := '<html><body><div style="text-align: left;">';
          S := S + '<div><h1>Error 404</h1></div>';
          S := S + '<hr><div>[ ' + html + Config.template_type + ' ] Not Find Page';
          S := S + '</div></div></body></html>';

        end;
        log('Error 404 [ ' + html + Config.template_type + ' ] Not Find Page');
        Response.Content := S;
      end
      else
      begin
        page := TPage.Create(S, params, self.url);
        try
          htmlcontent := page.HTML;
          if not Config.open_debug then
            _PageCache.PageList.AddOrSetValue(S, htmlcontent);
        finally
          page.Free;
        end;
        htmlpars.Parser(htmlcontent, params, self.url);
        Response.Content := htmlcontent;
      end;
    end;
  end
  else
  begin
    Response.Content := '未指定模板文件';
  end;
  Response.SendResponse;
end;

procedure TView.ShowJSON(json: string);
var
  S, value: string;
  matchs: TMatchCollection;
  match: TMatch;
begin
  Response.ContentType := 'application/json; charset=' + Config.document_charset;
  Response.Content := json;
  Response.SendResponse;
end;

procedure TView.ShowPage(count: Integer; jsondata: string);
var
  json: string;
begin
  json := '{';
  json := json + '"code":0,';
  json := json + '"msg":"",';
  json := json + '"count:"' + count.ToString;
  json := json + '"data":' + jsondata;
  ShowJSON(json);
end;

procedure TView.ShowJSON(jo: ISuperObject);
begin
  if jo = nil then
    jo := so();
  ShowJSON(jo.AsJSON());
end;

procedure TView.ShowPage(count: Integer; data: ISuperObject);
var
  json: ISuperObject;
  s: string;
begin

  json := SO();
  json.I['code'] := 0;
  json.S['msg'] := '';
  json.I['count'] := count;
  json.A['data'] := data.AsArray;
  ShowJSON(json.AsJSON());
end;

function TView.Cookies: TCookie;
begin
  result := Response.Cookies.Add;
end;

procedure TView.CookiesSet(key, value: string);
begin
  Request.CookieFields.Values[key] := value;
end;

function TView.CookiesValue(key: string): string;
begin
  result := Request.CookieFields.Values[key];
end;

constructor TView.Create(Response_: TWebResponse; Request_: TWebRequest; ActionPath, ActionRoule: string);
begin

  Plugin := TPlugin.Create;
  params := TStringList.Create;
//  Db := TDBConfig.Create();
//  DbItem:= getDbFromPool;
//  Db:=DbItem.Db;
  htmlpars := THTMLParser.Create();
  setData(Response_, Request_, ActionPath, ActionRoule);
end;

function TView.InputByIndex(index: Integer): string;
var
  s, s1: string;
  params: TStringList;
begin
  params := TStringList.Create;
  try
    s1 := ActionR;
    s := Request.PathInfo;
    s := Copy(s, Length(s1) + 1, Length(s) - Length(s1));

    params.Delimiter := '/';
    params.DelimitedText := s;
    if (index < params.Count) and (index > -1) then
    begin
      s := params.Strings[index];
    end
    else
    begin
      s := '';
    end;
    Result := s;
  finally
    params.Free;
  end;
end;

procedure TView.CreateSession;
var
  timerout: TDateTime;
begin

  sessionid := CookiesValue(_SessionName);
  if sessionid = '' then
  begin
    sessionid := GetGUID();
  end;
  timerout := Now + (1 / 24 / 60) * Config.session_timer;
  with Cookies do
  begin
    Path := '/';
    Name := _SessionName;
    value := sessionid;
    Expires := timerout;
  end;
  _SessionListMap.editTimerOut(sessionid, DateTimeToStr(timerout));
end;

function TView.GetGUID: string;
var
  LTep: TGUID;
  sGUID: string;
begin
  CreateGUID(LTep);
  sGUID := GUIDToString(LTep);
  sGUID := StringReplace(sGUID, '-', '', [rfReplaceAll]);
  sGUID := Copy(sGUID, 2, Length(sGUID) - 2);
  result := sGUID;
end;

destructor TView.Destroy;
begin

  if (Redisitem <> nil) and (_RedisList <> nil) then
  begin
    _RedisList.CloseRedis(Redisitem.guid);
  end;
  htmlpars.Free;
  params.Free;
  Plugin.Free;
 // Db.Free;
  inherited;
end;

procedure TView.Fail(code: Integer; msg: string);
var
  jo: ISuperObject;
begin
  jo := SO();
  jo.I['code'] := code;
  if Trim(msg) = '' then
    msg := '操作成功';
  jo.S['message'] := msg;
  ShowJSON(jo);
end;

procedure TView.FreeDb;
begin
  FreeDbToPool(DbItem);
end;

function TView.Input(param: string): string;
begin
  if (Request.MethodType = mtPost) then
  begin
    result := Request.ContentFields.Values[param];
  end
  else if (Request.MethodType = mtGet) then
  begin
    result := Request.QueryFields.Values[param];
  end;
end;

function TView.InputInt(param: string): Integer;
begin
  Result := StrToInt(Input(param));
end;

function TView.InputToJSON: ISuperObject;
var
  jo: ISuperObject;
  i: Integer;
begin
  jo := so();
  for i := 0 to Request.QueryFields.Count - 1 do
    jo.S[Request.QueryFields.Names[i]] := Request.QueryFields.ValueFromIndex[i];
  for i := 0 to Request.ContentFields.Count - 1 do
    jo.S[Request.ContentFields.Names[i]] := Request.ContentFields.ValueFromIndex[i];
  Result := jo;
end;

procedure TView.makeSession;
var
  timerout: TDateTime;
begin
  if _RedisList <> nil then
  begin
    RedisSetKeyJSON(sessionid, SO('{}'), Config.session_timer);
  end
  else
  begin
    if (Config.session_timer <> 0) then
      timerout := Now + (1 / 24 / 60) * Config.session_timer
    else
      timerout := Now + (1 / 24 / 60) * 60 * 24; //24小时过期
    _SessionListMap.setValueByKey(sessionid, '{}');
    _SessionListMap.setTimeroutByKey(sessionid, DateTimeToStr(timerout));
  end;
 // log('创建Session:' + sessionid);
end;

function TView.Q(str: string): string;
begin
  result := '''' + str + '''';
end;

procedure TView.Redirect(action: string; path: string = '');
var
  S: string;
begin
  S := Config.__APP__ + '/';
  if action.Trim <> '' then
    S := S + action + '/';
  if path.Trim <> '' then
    S := S + path;
  Response.SendRedirect(S);
  ShowText(S);
end;

procedure TView.SessionSet(key, value: string);
var
  s: string;
  jo: ISuperObject;
begin
  if (not Config.session_start) then
    exit;
  if _RedisList <> nil then
  begin
    s := JsonToString(RedisGetKeyJSON(sessionid).AsJSON);
  end
  else
  begin
    s := _SessionListMap.getValueByKey(sessionid);
  end;
  if (s = '') or (s = '{}') then
  begin
    makeSession;
    s := '{}';
  end;
  jo := SO(s);
  jo.S[key] := value;
  if _RedisList <> nil then
  begin
    RedisSetKeyJSON(sessionid, jo);
  end
  else
  begin
    _SessionListMap.setValueByKey(sessionid, JsonToString(jo.AsJSON()));
  end;
end;

procedure TView.SessionSetJSON(key: string; json: ISuperObject);
begin
  if json <> nil then
    SessionSet(key, JsonToString(json.AsJSON));
end;

function TView.SessionCount: integer;
begin
  if (not Config.session_start) then
    exit;
  if _RedisList <> nil then
    Result := RedisGetKeyCount
  else
    Result := _SessionListMap.SessionLs_vlue.Count;
end;

function TView.SessionDestroy: Boolean;
begin
  if (not Config.session_start) then
    exit;
  if _RedisList <> nil then
    Result := RedisRemove(sessionid)
  else
  begin
    Result := _SessionListMap.deleteSession(sessionid);
  end;
end;

function TView.SessionGet(key: string): string;
var
  s: string;
  jo: ISuperObject;
begin
  if (not Config.session_start) then
    exit;
  if _RedisList <> nil then
    s := JsonToString(RedisGetKeyJSON(sessionid).AsJSON())
  else
    s := _SessionListMap.getValueByKey(sessionid);
  if s = '' then
  begin
    Result := '';
  end
  else
  begin
    jo := SO(s);
    Result := jo.S[key];
  end;
end;

function TView.SessionGetJSON(key: string): ISuperObject;
begin
  Result := SO(SessionGet(key));
end;

function TView.SessionRemove(key: string): Boolean;
var
  s: string;
  jo: ISuperObject;
begin
  Result := true;
  if (not Config.session_start) then
    exit;
  try
    if _RedisList <> nil then
      s := JsonToString(RedisGetKeyJSON(sessionid).AsJSON())
    else
      s := _SessionListMap.getValueByKey(sessionid);
    if s = '' then
    begin
      Result := false;
      exit;
    end;
    jo := SO(s);
    jo.Remove(key);
    if _RedisList <> nil then
      RedisSetKeyJSON(sessionid, jo)
    else
      _SessionListMap.setValueByKey(sessionid, JsonToString(jo.AsJSON()));
  except
    Result := false;
  end;
end;

procedure TView.ShowJSON(cds: TFDQuery);
var
  json: string;
begin
  json := '';
  if (cds <> nil) and (cds.Active) then
  begin
    json := CDSToJSONText(cds);
  end;
  ShowJSON(json);
end;

end.

