{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}


unit BaseController;

interface

uses
  System.Classes, System.SysUtils, Web.HTTPApp, View, IdCustomHTTPServer, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, IdURI, IdGlobal, RedisM,
  RedisList, superobject;

type
  TBaseController = class
  private
    RedisM: TRedisM;
    RedisItem: TRedisItem;
    FRequest: TWebRequest;
    FResponse: TWebResponse;
    FActionPath: string;
    procedure SetRequest(const Value: TWebRequest);
    procedure SetResponse(const Value: TWebResponse);
    procedure SetActionPath(const Value: string);
  protected
  public
    View: TView;
    Error: Boolean;
    function isPOST: Boolean;
    function isGET: Boolean;
    function isPut: Boolean;
    function isAny: Boolean;
    function isDelete: Boolean;
    function isHead: Boolean;
    function isPatch: Boolean;
    function isNil(text: string): Boolean;
    function isNotNil(text: string): Boolean;
    procedure RedisSetKeyText(key: string; value: string; timerout: Integer = 0);
    function RedisGetKeyText(key: string): string;
    procedure RedisSetKeyJSON(key: string; value: ISuperObject; timerout: Integer = 0);
    function RedisGetKeyJSON(key: string): ISuperObject;
    procedure RedisSetExpire(key: string; timerout: Integer);
    function URLDecode(Asrc: string; AByteEncoding: IIdTextEncoding = nil): string;
    function URLEncode(Asrc: string; AByteEncoding: IIdTextEncoding = nil): string;
    function Interceptor: boolean;
    procedure CreateView();
    function HttpGet(url: string; encode: TEncoding): string;
    constructor Create();
    destructor Destroy; override;
    function AppPath: string; //获取项目物理路径
    property Request: TWebRequest read FRequest write SetRequest;
    property Response: TWebResponse read FResponse write SetResponse;
    property ActionPath: string read FActionPath write SetActionPath;
  end;

implementation

uses
  command, uConfig;

{ TBaseController }
function TBaseController.Interceptor: boolean;
begin
  if open_interceptor then
  begin
    Result := _interceptor.execute(View, Error);
  end
  else
  begin
    Result := false;
  end;

end;

function TBaseController.isAny: Boolean;
begin
  Result := Request.MethodType = mtAny;
end;

function TBaseController.isDelete: Boolean;
begin
  Result := Request.MethodType = mtDelete;
end;

function TBaseController.isGET: Boolean;
begin
  Result := Request.MethodType = mtGet;
end;

function TBaseController.isHead: Boolean;
begin
  Result := Request.MethodType = mtHead;
end;

function TBaseController.isNil(text: string): Boolean;
begin
  if (Trim(text) = '') then
    Result := true
  else
    Result := false;
end;

function TBaseController.isNotNil(text: string): Boolean;
begin
  Result := not isNil(text);
end;

function TBaseController.isPatch: Boolean;
begin
  Result := Request.MethodType = mtPatch;
end;

function TBaseController.isPOST: Boolean;
begin
  Result := Request.MethodType = mtPost;
end;

function TBaseController.isPut: Boolean;
begin
  Result := Request.MethodType = mtPut;
end;

function TBaseController.RedisGetKeyJSON(key: string): ISuperObject;
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

function TBaseController.RedisGetKeyText(key: string): string;
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

procedure TBaseController.RedisSetExpire(key: string; timerout: Integer);
begin
  if (_RedisList <> nil) then
    RedisM.setExpire(key, timerout);
end;

procedure TBaseController.RedisSetKeyJSON(key: string; value: ISuperObject; timerout: Integer);
begin
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    RedisM.setKeyJSON(key, value, timerout);
end;

procedure TBaseController.RedisSetKeyText(key, value: string; timerout: Integer);
begin
  if (_RedisList <> nil) and (RedisItem = nil) then
  begin
    RedisItem := _RedisList.OpenRedis();
    RedisM := RedisItem.item;
  end;
  if (_RedisList <> nil) then
    RedisM.setKeyText(key, value, timerout);
end;

procedure TBaseController.SetActionPath(const Value: string);
begin
  FActionPath := Value;
end;

procedure TBaseController.SetRequest(const Value: TWebRequest);
begin
  FRequest := Value;
end;

procedure TBaseController.SetResponse(const Value: TWebResponse);
begin
  FResponse := Value;
end;

function TBaseController.URLDecode(Asrc: string; AByteEncoding: IIdtextEncoding): string;
begin
  if AByteEncoding <> nil then
    Result := TIdURI.URLDecode(Asrc, AByteEncoding)
  else
    Result := TIdURI.URLDecode(Asrc);
end;

function TBaseController.URLEncode(Asrc: string; AByteEncoding: IIdTextEncoding): string;
begin
  if AByteEncoding <> nil then
    Result := TIdURI.URLEncode(Asrc, AByteEncoding)
  else
    Result := TIdURI.URLEncode(Asrc);
end;

function TBaseController.AppPath: string;
begin
  Result := WebApplicationDirectory;
end;

constructor TBaseController.Create();
begin
  View := nil;
  ActionPath := '';
  RedisItem := nil;
  RedisM := nil;
end;

procedure TBaseController.CreateView;
begin
  try
    View := TView.Create(Response, Request, ActionPath);
    RedisItem := nil;
  except
    on e: Exception do
    begin
      self.Response.Content := e.ToString;
      Error := true;
    end;
  end;
end;

destructor TBaseController.Destroy;
begin
  if (Redisitem <> nil) and (_RedisList <> nil) then
  begin
    _RedisList.CloseRedis(Redisitem.guid);
  end;
  FreeAndNil(View);
  inherited;
end;

function TBaseController.HttpGet(url: string; encode: TEncoding): string;
var
  http: TNetHTTPClient;
  html: TStringStream;
  ret: string;
begin
  ret := '';
  if Trim(url) <> '' then
  begin
    try
      http := TNetHTTPClient.Create(nil);
      html := TStringStream.Create('', encode);
      http.UserAgent := 'User-Agent:Mozilla/4.0(compatible;MSIE7.0;WindowsNT5.1;360SE)';
      try
        http.Get(url, html);
        ret := (html.DataString);
      except
        ret := '请求异常';
      end;
    finally
      html.Clear;
      FreeAndNil(html);
      FreeAndNil(http);
    end;
  end;
  Result := ret;
end;

end.

