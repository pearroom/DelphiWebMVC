{*******************************************************}
{                                                       }
{       DelphiWebMVC 5.0                                }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2022-2 苏兴迎(PRSoft)              }
{                                                       }
{*******************************************************}
unit MVC.Controller;

interface

uses
  System.Classes, System.SysUtils, Web.HTTPApp, Web.ReqMulti, System.JSON,
  System.Net.URLClient, MVC.JSON, System.Net.HttpClientComponent, IdURI,
  MVC.TplParser, IdGlobal, MVC.Config, MVC.Session, MVC.TplUnit, MVC.LogUnit,
  MVC.DataSet;

type
  THTTPMethod = (None, GET, POST, PUT, HEAD, DELETE, PATCH, OPTIONS);

  TMURL = class(TCustomAttribute)
  private
    httpMethod: THTTPMethod;
    function FmtURL(url: string): string;
  public
    routeUrl: string;
    tplPath: string;
    function getMethodType: string;
    constructor Create(sRouteUrl: string; sMethod: THTTPMethod = THTTPMethod.None); overload;
    constructor Create(sRouteUrl: string; sTplPath: string; sMethod: THTTPMethod = THTTPMethod.None); overload;
  end;

  TController = class
  private
    PageParams: TStringList;
    FRequest: TWebRequest;
    FResponse: TWebResponse;
    FWebPath: string;
    FRouteUrl: string;
    FtplPath: string;
    FSession: TSession;
    procedure SetRequest(const Value: TWebRequest);
    procedure SetResponse(const Value: TWebResponse);
    procedure SetRouteUrl(const Value: string);
    procedure SettplPath(const Value: string);
    procedure Corss_Origin;

  public
    function Q(str: string): string;
    function UpFiles(filedir: string = ''; filename: string = ''): string; //接收上传文件
    function GetGUID: string;
    function Input(param: string): string;
    function InputByIndex(index: Integer): string;
    function InputToJSON: IJObject;
    function InputToJSONArray: IJArray;
    function InputBody: string;  //返回请求内容
    function InputInt(param: string): Integer;
    property Session: TSession read FSession;
    property WebPath: string read FWebPath; //系统物理根目录
    property Request: TWebRequest read FRequest write SetRequest;
    property Response: TWebResponse read FResponse write SetResponse;
    property RouteUrl: string read FRouteUrl write SetRouteUrl;
    property tplPath: string read FtplPath write SettplPath;
    procedure SetAttr(key: string; ds: IDataSet); overload;
    procedure SetAttr(key, value: string); overload;
    procedure SetAttr(key: string; json: IJObject); overload;
    procedure SetAttr(key: string; JsonArray: IJArray); overload;
    procedure ShowText(text: string);
    procedure ShowXMLTpl(xmlTpl: string);
    procedure ShowXML(xml: string);
    procedure ShowJSON(json: string); overload;
    procedure ShowJSON(jsonJO: IJObject); overload;
    procedure ShowJSON(jsonJA: IJArray); overload;
    procedure ShowJSON(dataset: IDataSet); overload;
    procedure ShowJSON(res: TResData); overload;
    procedure Show(htmlTpl: string);
    /// <param name="isdown">是否下载文件</param>
    procedure ShowFile(AFileName: string; isDown: Boolean = false);
    procedure Success(code: Integer = 0; msg: string = '');
    procedure Fail(code: Integer = -1; msg: string = '');

    procedure Redirect(action: string; path: string = '');

    function Intercept(): Boolean; virtual; //访问拦截处理方法需子类继承使用
    procedure CreateController; virtual; //控制器创建
    destructor Destroy; override;
  end;

implementation

{ TBaseController }
function TController.GetGUID: string;
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

procedure TController.Corss_Origin;
var
  s: string;
begin
  s := Config.Corss_Origin.Allow_Origin;
  if s <> '' then
  begin
    Response.SetCustomHeader('Access-Control-Allow-Origin', s);
    s := Config.Corss_Origin.Allow_Headers;
    if s <> '' then
      Response.SetCustomHeader('Access-Control-Allow-Headers', s);
    s := Config.Corss_Origin.Allow_Method;
    if s <> '' then
      Response.SetCustomHeader('Access-Control-Allow-Method', s);
    if Config.Corss_Origin.Allow_Credentials then
      Response.SetCustomHeader('Access-Control-Allow-Method', 'true')
    else
      Response.SetCustomHeader('Access-Control-Allow-Method', 'false');
  end;
end;

procedure TController.CreateController;
begin
  FWebPath := Config.BasePath;
  PageParams := TStringList.Create;
  FSession := TSession.Create(Request, Response);
end;

destructor TController.Destroy;
begin
  FSession.Free;
  PageParams.Free;
  inherited;
end;

procedure TController.Fail(code: Integer; msg: string);
var
  jo: IJObject;
begin
  jo := IIJObject();
  if Trim(msg) = '' then
    msg := '操作失败';
  jo.O.AddPair('code', TJSONNumber.Create(code));
  jo.O.AddPair('message', msg);
  ShowJSON(jo);
end;

function TController.Intercept: Boolean;
begin
  Result := false;
end;

function TController.Q(str: string): string;
begin
  result := QuotedStr(str);
end;

procedure TController.Redirect(action, path: string);
var
  S: string;
begin
  S := Config.APP + '/';
  if action.Trim <> '' then
    S := S + action + '/';
  if path.Trim <> '' then
    S := S + path;
  Response.SendRedirect(S);
  ShowText(S);
end;

procedure TController.SetAttr(key: string; json: IJObject);
begin
  if json <> nil then
  begin
    setAttr(key, json.toJSON);
  end;
end;

procedure TController.SetAttr(key, value: string);
begin
  if value.Trim = '' then
    value := ' ';
  PageParams.Values[key] := value;
end;

procedure TController.SetRequest(const Value: TWebRequest);
begin
  FRequest := Value;
end;

procedure TController.SetResponse(const Value: TWebResponse);
begin
  FResponse := Value;
end;

procedure TController.SetRouteUrl(const Value: string);
begin
  FRouteUrl := Value;
end;

procedure TController.SettplPath(const Value: string);
begin
  FtplPath := Value;
end;

procedure TController.ShowFile(AFileName: string; isDown: Boolean);
var
  sFileName: string;
begin
  sFileName := AFileName;
  if ExtractFileDrive(sFileName) = '' then
    sFileName := Config.WebRoot + sFileName;

  sFileName := sFileName.Replace('/', '\');
  Response.Content := sFileName;
  Response.ContentType := '!STATICFILE';
  if not isDown then
    //浏览器内显示
    Response.SetCustomHeader('Content-Disposition', 'inline;filename=' + ExtractFileName(sFileName))
  else
    //下载文件
    Response.SetCustomHeader('Content-Disposition', 'attachment;filename=' + ExtractFileName(sFileName));

  Response.ContentEncoding := Config.document_charset;
end;

procedure TController.Show(htmlTpl: string);
var
  key: string;
  htmlcontent: string;
  pagepars: TTplParser;
  suff: string;
begin

  if htmlTpl.Trim = '' then
    exit;

  suff := '';
  if Pos('.', htmlTpl) < 1 then
  begin
    suff := Config.template_type;
  end;

  htmlTpl := htmlTpl.Replace('/', '\');
  if htmlTpl.Substring(0, 1) = '\' then
  begin
    key := htmlTpl + suff;
  end
  else
  begin
    if tplPath <> '' then
      tplPath := tplPath + '\';
    key := tplPath + htmlTpl + suff;
  end;

  try
    htmlcontent := PageCache.LoadPage(key);
    if htmlcontent = '' then
    begin
      htmlcontent := '<h1>模板文件不存在</h1><hr>' + key;
    end
    else
    begin
      pagepars := TTplParser.Create;
      try
        pagepars.Parser(htmlcontent, PageParams, tplPath);
      finally
        pagepars.Free;
      end;
    end;
  finally
    Response.ContentType := 'text/html; charset=' + Config.document_charset;
    Response.Content := htmlcontent;
  end;
end;

procedure TController.ShowJSON(dataset: IDataSet);
begin
  ShowJSON(dataset.toJSONArray)
end;

procedure TController.ShowJSON(res: TResData);
begin
  Success(res.Code, res.Msg);
end;

procedure TController.ShowJSON(jsonJA: IJArray);
begin
  ShowJSON(jsonJA.ToJSON);
end;

procedure TController.ShowJSON(jsonJO: IJObject);
begin
  ShowJSON(jsonJO.ToJSON);
end;

procedure TController.ShowJSON(json: string);
begin
  Corss_Origin;
  Response.ContentType := 'application/json; charset=' + Config.document_charset;
  Response.Content := json;
end;

procedure TController.ShowText(text: string);
begin
  Corss_Origin;
  Response.ContentType := 'text/html; charset=' + Config.document_charset;
  Response.Content := text;
end;

function TController.InputInt(param: string): Integer;
begin
  Result := StrToInt(Input(param));
end;

function TController.InputBody: string;
begin
  Result := Request.Content;
end;

function TController.InputByIndex(index: Integer): string;
var
  s, s1: string;
  params: TStringList;
begin
  params := TStringList.Create;
  try
    s1 := RouteUrl;
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

function TController.InputToJSON: IJObject;
var
  jo: IJObject;
  i: Integer;
  isok: boolean;
  key, value: string;
  body: string;
begin
  isok := False;
  body := InputBody;
  try
    if body.Trim <> '' then
    begin
      if (body.Substring(0, 1) = '[') and (body.Substring(body.Length - 1, 1) = ']') then
        exit;   //不处理json数组由InputToJSONArray处理
      if (body.Substring(0, 1) = '{') and (body.Substring(body.Length - 1, 1) = '}') then
      begin
        try
          jo := IIJObject(body);
          isok := true;
        except
          jo := nil;
        end;
      end
      else if Request.ContentFields.Count > 0 then
      begin
        jo := IIJObject();
        for i := 0 to Request.ContentFields.Count - 1 do
        begin
          key := Request.ContentFields.Names[i];
          value := Request.ContentFields.ValueFromIndex[i];
          if (key.Trim <> '') and (value.Trim <> '') then
          begin
            isok := True;
            jo.O.AddPair(key, value);
          end;
        end;
      end;
    end
    else
    begin
      jo := IIJObject();
      for i := 0 to Request.QueryFields.Count - 1 do
      begin
        key := Request.QueryFields.Names[i];
        value := Request.QueryFields.ValueFromIndex[i];
        if (key.Trim <> '') and (value.Trim <> '') then
        begin
          jo.O.AddPair(key, value);
          isok := True;
        end;
      end;
    end;
  finally
    if not isok then
      jo := nil;
    Result := jo;
  end;
end;

function TController.InputToJSONArray: IJArray;
var
  ja: IJArray;
  body: string;
begin
  body := InputBody;
  if body.Trim <> '' then
  begin
    if (body.Substring(0, 1) = '[') and (body.Substring(body.Length - 1, 1) = ']') then
    begin
      try
        ja := IIJArray(body);
      except
        ja := nil;
      end;
    end
  end;
  Result := ja;
end;

function TController.Input(param: string): string;
begin
  if (Request.MethodType = mtPost) then
  begin
    result := Request.ContentFields.Values[param];
    if Trim(Result) = '' then
      result := Request.QueryFields.Values[param];
  end
  else if (Request.MethodType = mtGet) then
  begin
    result := Request.QueryFields.Values[param];
  end;
end;

procedure TController.ShowXML(xml: string);
begin
  Response.ContentType := 'application/xml; charset=' + Config.document_charset;
  Response.Content := xml;
end;

procedure TController.ShowXMLTpl(xmlTpl: string);
var
  key, xmlcontent: string;
  pagepars: TTplParser;
  pagefile: string;
  page: TPage;
  suff: string;
begin
  Corss_Origin;

  if xmlTpl.Trim = '' then
    exit;

  suff := '';
  if Pos('.', xmlTpl) < 1 then
  begin
    suff := '.xml';
  end;

  xmlTpl := xmlTpl.Replace('/', '\');
  if xmlTpl.Substring(0, 1) = '\' then
  begin
    key := xmlTpl + suff;
  end
  else
  begin
    if tplPath <> '' then
      tplPath := tplPath + '\';
    key := tplPath + xmlTpl + suff;
  end;

  xmlcontent := PageCache.LoadPage(key);
  if xmlcontent <> '' then
  begin
    pagepars := TTplParser.Create;
    try
      pagepars.Parser(xmlcontent, PageParams, tplPath);
    finally
      pagepars.Free;
    end;
    ShowXML(xmlcontent);
  end;

  if xmlcontent.Trim = '' then
  begin
    Response.StatusCode := 404;
    pagefile := WebPath + config.WebRoot + '\' + Config.Error404 + Config.template_type;
    page := TPage.Create(pagefile);
    try
      xmlcontent := page.Error404(key);
    finally
      page.Free;
    end;
    ShowText(xmlcontent);
  end;
end;

procedure TController.Success(code: Integer; msg: string);
var
  jo: IJObject;
begin
  jo := IIJObject();
  if Trim(msg) = '' then
    msg := '操作成功';
  jo.O.AddPair('code', TJSONNumber.Create(code));
  jo.O.AddPair('message', msg);
  ShowJSON(jo);
end;

function TController.UpFiles(filedir: string = ''; filename: string = ''): string;
var
  k: integer;
  path, s, FFileName: string;
  Afile: TFileStream;
  i: Integer;
  p, ret, filetmp: string;
begin
  k := Request.Files.Count - 1;
  if k = -1 then
  begin
    ret := '';
    Result := ret;
    exit;
  end;
  for i := 0 to k do
  begin
    if filedir.Trim <> '' then
      path := WebPath + filedir.Trim
    else
      path := WebPath + 'upfile';
    if not DirectoryExists(path) then
    begin
      CreateDir(path);
    end;
    s := ExtractFileName(Request.Files[i].filename);
    if filename.Trim <> '' then
    begin
      p := '';
      if i > 0 then
        p := i.ToString;
      filetmp := filename.Trim + p + copy(s, Pos('.', s), s.Length - pos('.', s) + 1)
    end
    else
    begin
      filetmp := GetGUID + copy(s, Pos('.', s), s.Length - pos('.', s) + 1);
    end;
    FFileName := path + '\' + filetmp;
    Afile := TFileStream.Create(FFileName, fmCreate);
    try
      Request.Files[i].Stream.Position := 0;
      Afile.CopyFrom(Request.Files[i].Stream, Request.Files[i].Stream.Size);  //测试保存文件，通过。
    finally
      Afile.Free;
    end;
    ret := ret + filetmp + ',';
  end;
  ret := ret.Substring(0, ret.Length - 1);
  Result := ret;
end;

procedure TController.SetAttr(key: string; JsonArray: IJArray);
begin
  if JsonArray <> nil then
  begin
    setAttr(key, JsonArray.toJSON);
  end;
end;

procedure TController.SetAttr(key: string; ds: IDataSet);
begin
  setAttr(key, ds.toJSONArray);
end;

function TMURL.FmtURL(url: string): string;
var
  s: string;
begin
  s := url;
  if s.Trim <> '' then
  begin
    s := s.Replace('\\', '/').Replace('//', '/').Replace('\', '/');
    if s.Substring(0, 1) = '/' then
      s := s.Substring(1, s.Length);
    if s.Substring(s.Length - 1, 1) = '/' then
      s := s.Substring(0, s.Length - 1);
  end;
  Result := s;
end;

constructor TMURL.Create(sRouteUrl: string; sMethod: THTTPMethod);
begin

  routeUrl := FmtURL(sRouteUrl);
  tplPath := '';
  httpMethod := sMethod
end;

constructor TMURL.Create(sRouteUrl, sTplPath: string; sMethod: THTTPMethod);
begin
  routeUrl := FmtURL(sRouteUrl);
  tplPath := FmtURL(sTplPath);
  httpMethod := sMethod
end;

function TMURL.getMethodType: string;
begin
  Result := '';
  case httpMethod of
    GET:
      result := 'GET';
    POST:
      result := 'POST';
    PUT:
      result := 'PUT';
    HEAD:
      result := 'HEAD';
    DELETE:
      result := 'DELETE';
    PATCH:
      result := 'PATCH';
    OPTIONS:
      result := 'OPTIONS';
  end;
end;

end.

