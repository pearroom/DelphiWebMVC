{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit View;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.HTTPProd, System.StrUtils,
  FireDAC.Comp.Client, Page, superobject, uConfig, Web.ReqMulti, Vcl.Imaging.jpeg,
  Vcl.Graphics, Data.DB, System.RegularExpressions, HTMLParser, SimpleXML,
  uDBConfig;

type
  TView = class
  private
    sessionid: string;
    htmlpars: THTMLParser;
    url: string; // 当前模板路径
    params: TStringList;
    function GetGUID: string;
    procedure CreateSession(); // 创建获取session
    procedure makeSession;
  public
    Db: TDBConfig;
   // Db2: TDB2; //第2个数据源
    ActionP: string;
    ActionR: string;
    Response: TWebResponse;
    Request: TWebRequest;
    function Q(str: string): string;
    procedure SessionSet(key, value: string);   // session控制 value传入json字符串作为对象存储
    procedure SessionSetJSON(key: string; json: ISuperObject);
    function SessionGet(key: string): string;   // session 值获取
    function SessionGetJSON(key: string): ISuperObject;   // session 值获取
    function SessionRemove(key: string): Boolean;
    function Cookies(): TCookie;                // cookies 操作
    function CookiesValue(key: string): string; // cookies 操作
    procedure CookiesSet(key, value: string);   // cookies 操作
    function Input(param: string): string;      // 返回参数值，get post
    function InputInt(param: string): Integer;      // 返回参数值，get post
    function InputByIndex(index: Integer): string;
    function CDSToJSON(cds: TFDQuery): string;
    procedure setAttr(key, value: string);      // 设置视图标记显示内容 ，如果 value是 json 数组可以在 table 标记中显示
    procedure setAttrJSON(key: string; json: ISuperObject);
    procedure ShowHTML(html: string);           // 显示模板
    procedure ShowText(text: string);           // 显示文本，json格式需转换后显示
    procedure ShowJSON(jo: ISuperObject);       // 显示 json
    procedure ShowXML(xml: IXmlDocument);        // 显示 xml 数据
    procedure ShowPage(count: Integer; data: ISuperObject);   //渲染分页数据
    procedure Redirect(action: string; path: string = '');        // 跳转 action 路由,path 路径
    procedure ShowVerifyCode(num: string);  // 显示验证码
    procedure Success(code: Integer = 0; msg: string = '');
    procedure Fail(code: Integer = -1; msg: string = '');
    constructor Create(Response_: TWebResponse; Request_: TWebRequest; ActionPath, ActionRoule: string);
    destructor Destroy; override;
  end;

implementation

uses
  SessionList, command, LogUnit;

{ TView }

function TView.CDSToJSON(cds: TFDQuery): string;
var
  ja, jo: ISuperObject;
  i: Integer;
  ret: string;
begin
  if not cds.Active then
    cds.OpenOrExecute;
  ja := SA([]);
  ret := '';
  with cds do
  begin
    First;
    while not Eof do
    begin
      jo := SO();
      for i := 0 to Fields.Count - 1 do
      begin
        jo.S[Fields[i].DisplayLabel] := Fields[i].AsString;
      end;
      ja.AsArray.Add(jo);
      Next;
    end;
    ret := ja.AsString;
  end;
  result := ret;
end;

procedure TView.setAttr(key, value: string);
begin
  params.Values[key] := value;
end;

procedure TView.setAttrJSON(key: string; json: ISuperObject);
begin
  if json <> nil then
    setAttr(key, json.AsString);
end;

procedure TView.ShowText(text: string);
begin

  Response.ContentType := 'text/html; charset=' + document_charset;
  Response.Content := text;
  Response.SendResponse;
end;

procedure TView.ShowXML(xml: IXmlDocument);
begin
  Response.ContentType := 'application/xml; charset=' + document_charset;
  Response.Content := xml.XML;
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
  Response.ContentType := 'text/html; charset=' + document_charset;
  if (Trim(html) <> '') then
  begin
    S := url + html + template_type;
    if (not FileExists(S)) then
    begin
      S := '<html><body><div style="text-align: left;">';
      S := S + '<div><h1>Error 404</h1></div>';
      S := S + '<hr><div>[ ' + html + template_type + ' ] Not Find Template';
      S := S + '</div></div></body></html>';
      Response.Content := S;
    end
    else
    begin
      try
        page := TPage.Create(S, params, self.url);
        htmlcontent := page.HTML;
      finally
        FreeAndNil(page);
      end;
      htmlpars.Parser(htmlcontent, params, self.url);
      Response.Content := htmlcontent;
    end;

  end
  else
  begin
    Response.Content := '未指定模板文件';
  end;
  Response.SendResponse;
end;

procedure TView.ShowJSON(jo: ISuperObject);
begin
  Response.ContentType := 'application/json; charset=' + document_charset;
  Response.Content := jo.AsJSon();
  Response.SendResponse;
end;

procedure TView.ShowPage(count: Integer; data: ISuperObject);
var
  json: ISuperObject;
begin
  json := SO();
  json.I['code'] := 0;
  json.S['msg'] := '';
  json.I['count'] := count;
  json.O['data'] := data;
  ShowJSON(json);

end;

procedure TView.ShowVerifyCode(num: string);
var
  bmp_t: TBitmap;
  jp: TJPEGImage;
  m: TMemoryStream;
  i: integer;
  s: string;
begin

  jp := TJPEGImage.Create;
  bmp_t := TBitmap.Create;
  m := TMemoryStream.Create;
  try
    bmp_t.SetSize(90, 35);
    bmp_t.Transparent := True;

    for i := 1 to length(num) do
    begin
      s := num[i];
      bmp_t.Canvas.Rectangle(0, 0, 90, 35);
      bmp_t.Canvas.Pen.Style := psClear;
      bmp_t.Canvas.Brush.Style := bsClear;

      bmp_t.Canvas.Font.Color := Random(256) and $C0; // 新建个水印字体颜色
      bmp_t.Canvas.Font.Size := Random(6) + 11;
      bmp_t.Canvas.Font.Style := [fsBold];
      bmp_t.Canvas.Font.Name := 'Verdana';

      bmp_t.Canvas.TextOut(i * 15, 5, s); // 加入文字

    end;
    jp.Assign(bmp_t);
    jp.CompressionQuality := 100;
    jp.Compress;
   // jp.SaveToFile('img.jpg');

    jp.SaveToStream(m);
    m.Position := 0;
    Response.ContentType := 'application/binary;';
    self.Response.ContentStream := m;
    Response.SendResponse;
  finally
    FreeAndNil(bmp_t);
    FreeAndNil(jp);
  end;

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
  Db := TDBConfig.Create();
  params := TStringList.Create;
  htmlpars := THTMLParser.Create(Db);
  self.ActionP := ActionPath;
  self.ActionR := ActionRoule;
  if (Trim(self.ActionP) <> '') then
  begin
    self.ActionP := self.ActionP + '/';
  end;
  url := WebApplicationDirectory + template + '/' + self.ActionP;
  self.Response := Response_;
  self.Request := Request_;

  if (session_start) then
    CreateSession();

end;

procedure TView.CreateSession;
begin

  sessionid := CookiesValue(SessionName);
  if sessionid = '' then
  begin
    sessionid := GetGUID();
    with Cookies() do
    begin
      Path := '/';
      Name := SessionName;
      value := sessionid;
    end;

  end;

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
  FreeAndNil(htmlpars);
  FreeAndNil(params);
  FreeAndNil(Db);
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

function TView.InputByIndex(index: Integer): string;
var
  s, s1: string;
  params: TStringList;
begin
  try
    s1 := ActionR;
    s := Request.PathInfo;
    s := Copy(s, Length(s1) + 1, Length(s) - Length(s1));
    params := TStringList.Create;
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

function TView.InputInt(param: string): Integer;
begin
  Result := StrToInt(Input(param));
end;

procedure TView.makeSession;
var
  timerout: TDateTime;
begin
  if (session_timer <> 0) then
    timerout := Now + (1 / 24 / 60) * session_timer
  else
    timerout := Now + (1 / 24 / 60) * 60 * 24; //24小时过期
  SessionListMap.setValueByKey(sessionid, '{}');
  SessionListMap.setTimeroutByKey(sessionid, DateTimeToStr(timerout));
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
  S := '';
  if action.Trim <> '' then
    S := '/' + action;
  if path.Trim <> '' then
    S := S + '/' + path;
  if S.Trim = '' then
    S := '/';
  Response.SendRedirect(S);
end;

procedure TView.SessionSet(key, value: string);
var
  s: string;
  jo: ISuperObject;
begin
  if (not session_start) then
    exit;

  s := SessionListMap.getValueByKey(sessionid);
  if (s = '') then
  begin
    makeSession;
    s := '{}';
  end;
  jo := SO(s);
  jo.S[key] := value;
  SessionListMap.setValueByKey(sessionid, jo.AsString);
end;

procedure TView.SessionSetJSON(key: string; json: ISuperObject);
begin
  if json <> nil then
    SessionSet(key, json.AsString);
end;

function TView.SessionGet(key: string): string;
var
  s: string;
  jo: ISuperObject;
begin
  if (not session_start) then
    exit;
  s := SessionListMap.getValueByKey(sessionid);
  if s = '' then
  begin
    Result := '';
  end
  else
  begin
    jo := SO(s);
    Result := jo.S[key];
  end;
 // result := SessionListMap.get(sessionid).jo.Values[key];
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
  if (not session_start) then
    exit;
  try
    s := SessionListMap.getValueByKey(sessionid);
    if s = '' then
    begin
      Result := false;
      exit;
    end;

    jo := SO(s);
    jo.Delete(key);
    SessionListMap.setValueByKey(sessionid, jo.AsString);
  except
    Result := false;
  end;
end;

end.

