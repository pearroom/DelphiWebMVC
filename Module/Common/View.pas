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
  Winapi.ActiveX;

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
    Db: TDB;
   // Db2: TDB2; //第2个数据源
    ActionP: string;
    Response: TWebResponse;
    Request: TWebRequest;
    function Q(str: string): string;
    procedure SessionSet(key, value: string);   // session控制 value传入json字符串作为对象存储
    function SessionGet(key: string): string;   // session 值获取
    function SessionRemove(key: string): Boolean;
    function Cookies(): TCookie;                // cookies 操作
    function CookiesValue(key: string): string; // cookies 操作
    procedure CookiesSet(key, value: string);   // cookies 操作
    function Input(param: string): string;      // 返回参数值，get post
    function InputInt(param: string): Integer;      // 返回参数值，get post
    function CDSToJSON(cds: TFDQuery): string;
    procedure setAttr(key, value: string);      // 设置视图标记显示内容 ，如果 value是 json 数组可以在 table 标记中显示
    procedure ShowHTML(html: string);           // 显示模板
    procedure ShowDSJSON(cds: TFDQuery);        // 数据集转换为json显示
    procedure ShowText(text: string);           // 显示文本，json格式需转换后显示
    procedure ShowJSON(jo: ISuperObject);       // 显示 json
    procedure ShowXML(xml: IXmlDocument);        // 显示 xml 数据
    procedure ShowPage(count: Integer; data: ISuperObject);   //渲染分页数据
    procedure Redirect(action: string; path: string = '');        // 跳转 action 路由,path 路径
    procedure ShowCheckIMG(num: string; width, height: Integer);  // 显示验证码
    procedure Success(code: Integer = 0; msg: string = '');
    procedure Fail(code: Integer = -1; msg: string = '');
    constructor Create(Response_: TWebResponse; Request_: TWebRequest; ActionPath: string);
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

procedure TView.ShowText(text: string);
begin

  Response.ContentType := 'text/html; charset=' + default_charset;
  Response.Content := text;
  Response.SendResponse;
end;

procedure TView.ShowXML(xml: IXmlDocument);
begin
  Response.ContentType := 'application/xml; charset=' + default_charset;
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
  Response.ContentType := 'text/html; charset=' + default_charset;
  if (Trim(html) <> '') then
  begin
    S := url + html + template_type;
    if (not FileExists(S)) then
      Response.Content := html + template_type + ' 模板文件未找到'
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
  Response.ContentType := 'application/json; charset=' + default_charset;
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

procedure TView.ShowCheckIMG(num: string; width, height: Integer);
var
  bmp_t: TBitmap;
  jp: TJPEGImage;
  m: TMemoryStream;
begin

  jp := TJPEGImage.Create;
  bmp_t := TBitmap.Create;
  try
    bmp_t.SetSize(width, height);
    bmp_t.Transparent := True;
    bmp_t.Canvas.Font.Color := clGreen; // 新建个水印字体颜色
    bmp_t.Canvas.Pen.Style := psClear;

    bmp_t.Canvas.Brush.Style := bsClear;

    bmp_t.Canvas.Font.Size := 16;
    bmp_t.Canvas.Font.Style := [fsBold];
    bmp_t.Canvas.Font.Name := 'Verdana';
    bmp_t.Canvas.TextOut(0, 5, num); // 加入文字
    // for I := 0 to 1 do
    // begin
    //
    // bmp_t.Canvas.Pen.Color:=clGreen;
    // bmp_t.Canvas.Pen.Width:=2;
    // bmp_t.Canvas.MoveTo(0,13+i*8);
    // bmp_t.Canvas.LineTo(width,13+i*8);
    //
    // end;
    jp.Assign(bmp_t);
    // jp.CompressionQuality := 25;

    // jp.Compress;
   // jp.SaveToFile('img.jpg');
    m := TMemoryStream.Create;

    jp.SaveToStream(m);
    m.Position := 0;
    self.Response.ContentType := 'image/jpeg';
    self.Response.ContentStream := m;
    //Response.SendResponse;
  finally
    bmp_t.Free;
    jp.Free;
  end;
end;

procedure TView.ShowDSJSON(cds: TFDQuery);
var
  ret: string;
begin
  try
    if not cds.Active then
      cds.OpenOrExecute;
    ret := Db.CDSToJSONArray(cds).AsString;

  except
    on E: Exception do
      ret := e.ToString;
  end;

  Response.Content := ret;
  Response.SendResponse;
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

constructor TView.Create(Response_: TWebResponse; Request_: TWebRequest; ActionPath: string);
begin
  Db := TDB.Create();
  params := TStringList.Create;
  htmlpars := THTMLParser.Create(Db);
  self.ActionP := ActionPath;
  if (Trim(self.ActionP) <> '') then
  begin
    self.ActionP := self.ActionP + '\';
  end;
  url := WebApplicationDirectory + template + '\' + self.ActionP;
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
  log('创建Session:' + sessionid);
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

