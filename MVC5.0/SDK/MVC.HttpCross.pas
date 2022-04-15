unit MVC.HttpCross;

interface

uses
  System.DateUtils, System.SysUtils, Classes, IniFiles, Contnrs, Web.WebReq,
  Web.HTTPProd, Web.ReqMulti, system.rtti, Web.HTTPApp, MVC.Config, IdURI,
  MVC.Route, MVC.LogUnit, WebBroker, Net.CrossHttpServer, Net.CrossHttpParams,
  Net.CrossSocket.Base, MVC.CrossCommon;

const
  // Request Header String
  cstInHeaderMethod = 0; // string
  cstInHeaderProtocolVersion = 1; // string
  cstInHeaderURL = 2; // string
  cstInHeaderQuery = 3; // string
  cstInHeaderPathInfo = 4; // string
  cstInHeaderPathTranslated = 5; // string
  cstInHeaderCacheControl = 6; // string
  cstInHeaderAccept = 8; // string
  cstInHeaderFrom = 9; // string
  cstInHeaderHost = 10; // string
  cstInHeaderReferer = 12; // string
  cstInHeaderUserAgent = 13; // string
  cstInContentEncoding = 14; // string
  cstInContentType = 15; // string
  cstInContentVersion = 17; // string
  cstInHeaderDerivedFrom = 18; // string
  cstInHeaderTitle = 20; // string
  cstInHeaderRemoteAddr = 21; // string
  cstInHeaderRemoteHost = 22; // string
  cstInHeaderScriptName = 23; // string
  cstInContent = 25; // string
  cstInHeaderConnection = 26; // string
  cstInHeaderCookie = 27; // string
  cstInHeaderAuthorization = 28; // string
  // Request Header Integer
  cstInContentLength = 16; // Integer
  cstInHeaderServerPort = 24; // Integer
  // Request Header DateTime
  cstInHeaderDate = 7; // TDateTime
  cstInHeaderIfModifiedSince = 11; // TDateTime
  cstInHeaderExpires = 19; // TDateTime
  // Response Header String
  cstOutHeaderVersion = 0; // string
  cstOutHeaderReasonString = 1; // string
  cstOutHeaderServer = 2; // string
  cstOutHeaderWWWAuthenticate = 3; // string
  cstOutHeaderRealm = 4; // string
  cstOutHeaderAllow = 5; // string
  cstOutHeaderLocation = 6; // string
  cstOutHeaderContentEncoding = 7; // string
  cstOutHeaderContentType = 8; // string
  cstOutHeaderContentVersion = 9; // string
  cstOutHeaderDerivedFrom = 10; // string
  cstOutHeaderTitle = 11; // string
  // Response Header Integer
  cstOutHeaderContentLength = 0; // Integer
  // Response Header DateTime
  cstOutHeaderDate = 0; // TDateTime
  cstOutHeaderExpires = 1; // TDateTime
  cstOutHeaderLastModified = 2; // TDateTime
  // Ver 0.0.0.2 +
  // CompilerVersion<Delphi2009 or CompilerVersion>Delphi 10 Seattle

var
  LContext: TRttiContext;


type
{$IF (CompilerVersion<20.0) OR (CompilerVersion>=30.0) }
  WBString = string;
{$ELSE}

  WBString = AnsiString;
{$IFEND}
{$IF CompilerVersion>33 }

  WBInt = Int64;
{$ELSE}

  WBInt = Integer;
{$IFEND}

type
  SockString = type RawByteString;

  THttpApi = class
  protected
    FHost, FMethod, FURL, FPathInfo, FQueryString, FAnchor: RawUTF8;
    FSSL: Boolean;
    FStatusCode: Integer;
    fOutContent: SockString;
    FRemoteIP: string;
    FRequest: ICrossHttpRequest;
    FResponse: ICrossHttpResponse;
    FQueryFields: TStrings;
    FContentFields: TStrings;
    FOutPutstream: TStream;
    function PrepareURL: RawUTF8; virtual;
    function GetContentFields: TStrings;
    procedure processMultiPartFormData; virtual;

  public
    property StatusCode: Integer read FStatusCode write FStatusCode;
    property Context: ICrossHttpResponse read FResponse;
    property Request: ICrossHttpRequest read FRequest;
    property Host: RawUTF8 read FHost;
    property Method: RawUTF8 read FMethod;
    property URL: RawUTF8 read FURL;
    property SSL: Boolean read FSSL;
    property PathInfo: RawUTF8 read FPathInfo;
    property QueryString: RawUTF8 read FQueryString;
    property Anchor: RawUTF8 read FAnchor;
    property RemoteIP: string read FRemoteIP;
    property QueryFields: TStrings read FQueryFields;
    property ContentFields: TStrings read GetContentFields;
    property OutContent: SockString read fOutContent write fOutContent;
    property OutPutstream: TStream read fOutPutstream;
    function GetHeader(const AUpKey: RawUTF8): RawUTF8;
    constructor Create(const ARequest: ICrossHttpRequest; AResponse: ICrossHttpResponse);
    destructor Destroy; override;
    function MethodAndPathInfo: RawUTF8;
    function GetRawContent: TBytes;
    procedure OutStream(const AStream: TStream; const AContentType: RawUTF8 = '');
    procedure OutFile(const AFileName: string);
    procedure OutHeader(const ANewHeaderAppended: RawUTF8);
    procedure Redirect(const AURI: string); overload;

  end;

  TRequest = class(TWebRequest)
  private
    function GetRequest: ICrossHttpRequest;
  protected
    FEnv: THttpApi;
    function GetStringVariable(Index: Integer): WBString; override;
    function GetDateVariable(Index: Integer): TDateTime; override;
    {$IF CompilerVersion=34 }
    function GetIntegerVariable(Index: Integer): WBInt;
    {$ELSE}
    function GetIntegerVariable(Index: Integer): WBInt; override;
    {$ENDIF}
    function GetInternalPathInfo: WBString; override;
    function GetInternalScriptName: WBString; override;
    function GetRemoteIP: WBString; override;
    function GetRawContent: TBytes; override;
  public
    property Request: ICrossHttpRequest read GetRequest;
    property Env: THttpApi read FEnv;
    constructor Create(const AEnv: THttpApi);
    // Read count bytes from client
    function ReadClient(var Buffer; Count: Integer): Integer; override;
    // Read count characters as a WBString from client
    function ReadString(Count: Integer): WBString; override;
    // Translate a relative URI to a local absolute path
    function TranslateURI(const URI: string): string; override;
    // Write count bytes back to client
    function WriteClient(var Buffer; Count: Integer): Integer; override;
    // Write WBString contents back to client
    function WriteString(const AString: WBString): Boolean; override;
    // Write HTTP header WBString
    function WriteHeaders(StatusCode: Integer; const ReasonString, Headers: WBString): Boolean; override;
    function GetFieldByName(const Name: WBString): WBString; override;
  end;

  TResponse = class(TWebResponse)
  private
    FSent: Boolean;
    function GetEnv: THttpApi;
    function GetResponse: ICrossHttpResponse;

  protected
    function GetStringVariable(Index: Integer): string; override;
    procedure SetStringVariable(Index: Integer; const Value: string); override;
    function GetDateVariable(Index: Integer): TDateTime; override;
    procedure SetDateVariable(Index: Integer; const Value: TDateTime); override;
    {$IF CompilerVersion=34 } //针对xe10.4去掉 override 问题
    function GetIntegerVariable(Index: Integer): WBInt;
    procedure SetIntegerVariable(Index: Integer; Value: WBInt);
    {$ELSE}
    function GetIntegerVariable(Index: Integer): WBInt; override;
    procedure SetIntegerVariable(Index: Integer; Value: WBInt); override;
    {$ENDIF}


    function GetContent: string; override;
    procedure SetContent(const Value: string); override;
    procedure SetContentStream(Value: TStream); override;
    function GetStatusCode: Integer; override;
    procedure SetStatusCode(Value: Integer); override;
    function GetLogMessage: string; override;
    procedure SetLogMessage(const Value: string); override;
    procedure OutCookiesAndCustomHeaders;
  public
    constructor Create(HTTPRequest: TRequest);
    property Response: ICrossHttpResponse read GetResponse;
    property Env: THttpApi read GetEnv;
    procedure SendResponse; override;
    procedure SendRedirect(const URI: WBString); override;
    procedure SendStream(AStream: TStream); override;
    function Sent: Boolean; override;
  end;

  TWebCrossHttpServer = class(TCrossHttpServer)
  protected
    procedure TriggerPostDataBegin(AConnection: ICrossHttpConnection); override;
    procedure TriggerPostData(AConnection: ICrossHttpConnection; const ABuf: Pointer; ALen: Integer); override;
  end;

  THTTPServer = class
  public
    HServer: ICrossHttpServer;
    Action: boolean;
    procedure Start;
    procedure Stop;
    procedure Process(Sender: TObject; ARequest: ICrossHttpRequest; AResponse: ICrossHttpResponse; var AHandled: Boolean);
    constructor Create();
    destructor Destroy; override;
  end;

var
  httpServer: THTTPServer;


function UTF8ToWBString(const AVal: RawUTF8): WBString;

function WBStringToUTF8(const AVal: WBString): RawUTF8;

implementation

{$IF (CompilerVersion<20.0) OR (CompilerVersion>30.0) }

function UTF8ToWBString(const AVal: RawUTF8): WBString;
begin
  Result := UTF8ToString(AVal);
end;

function WBStringToUTF8(const AVal: WBString): RawUTF8;
begin
  Result := StringToUTF8(AVal);
end;
{$ELSE}

function UTF8ToWBString(const AVal: RawUTF8): WBString;
begin
  Result := CurrentAnsiConvert.UTF8ToAnsi(AVal);
end;

function WBStringToUTF8(const AVal: WBString): RawUTF8;
begin
  Result := CurrentAnsiConvert.AnsiToUTF8(AVal);
end;
{$IFEND}

{ THTTPServer }

function InferContentType(const AFileName: string): RawUTF8;
var
  cExt: string;
begin
  Result := '';
  cExt := UpperCase(ExtractFileExt(AFileName));
  if (cExt = '.HTML') or (cExt = '.HTM') then
    Result := 'text/html; charset=UTF-8'
  else if cExt = '.JPG' then
    Result := 'image/jpeg'
  else if cExt = '.PNG' then
    Result := 'image/png'
  else if cExt = '.GIF' then
    Result := 'image/gif'
  else if cExt = '.ICO' then
    Result := 'image/x-icon'
  else if cExt = '.JS' then
    Result := 'application/x-javascript'
  else if cExt = '.CSS' then
    Result := 'text/css'
  else
    Result := 'application/octet-stream';
end;

constructor THTTPServer.Create;
begin
  LContext := TRttiContext.Create;
end;

destructor THTTPServer.Destroy;
begin
  if HServer.Active then
  begin
    HServer.Active := False;
  end;
  LContext.Free;
  inherited;
end;

procedure THTTPServer.Process(Sender: TObject; ARequest: ICrossHttpRequest; AResponse: ICrossHttpResponse; var AHandled: Boolean);
var
  LEnv: THttpApi;
  HTTPRequest: TRequest;
  HTTPResponse: TResponse;
begin

  LEnv := THttpApi.Create(ARequest, AResponse);
  HTTPRequest := TRequest.Create(LEnv);
  HTTPResponse := TResponse.Create(HTTPRequest);
  try
    OpenRoute(HTTPRequest, HTTPResponse);
  finally
    LEnv.Free;
    HTTPRequest.free;
    HTTPResponse.free;
  end;
end;

procedure THTTPServer.Start;
var
  compress: string;
begin
  if not Assigned(HServer) then
  begin
    try
      HServer := TWebCrossHttpServer.Create(Config.ThreadCount);
      HServer.Addr := IPv4v6_ALL;
      HServer.Port := Config.Port.ToInteger;

      compress := Config.Compress;
      if UpperCase(compress) = UpperCase('deflate') then
        HServer.Compressible := True
      else if UpperCase(compress) = UpperCase('gzip') then
        HServer.Compressible := True
      else
      begin
        HServer.Compressible := False;
      end;
      HServer.OnRequest := Process;
      HServer.Active := true;
      Action := true;
      log('服务启动');
    except
      on E: Exception do
        log('服务启动失败：' + e.Message);
    end;
  end;
end;

procedure THTTPServer.Stop;
begin
  log('服务停止');
end;

{ TWebCrossHttpServer }

procedure TWebCrossHttpServer.TriggerPostData(AConnection: ICrossHttpConnection; const ABuf: Pointer; ALen: Integer);
var
  LRequest: TCrossHttpRequest;
begin
  LRequest := AConnection.Request as TCrossHttpRequest;
  (LRequest.Body as TBytesStream).Write(ABuf^, ALen);
  if Assigned(OnPostData) then
    OnPostData(Self, AConnection, ABuf, ALen);
end;

procedure TWebCrossHttpServer.TriggerPostDataBegin(AConnection: ICrossHttpConnection);
var
  LRequest: TCrossHttpRequest;
  LMultiPart: THttpMultiPartFormData;
  LStream: TStream;
  LType: TRttiType;
  LField: TRttiField;
  LBody: TObject;

begin
  LRequest := AConnection.Request as TCrossHttpRequest;

  LType := LContext.GetType(TCrossHttpRequest);
  LField := LType.GetField('FBody');
  LBody := LField.GetValue(LRequest).AsObject;
  FreeAndNil(LBody);
  LStream := TBytesStream.Create(nil);
  LField.SetValue(LRequest, LStream);
  if Assigned(OnPostDataBegin) then
    OnPostDataBegin(Self, AConnection);
end;

{ THttpApi }

constructor THttpApi.Create(const ARequest: ICrossHttpRequest; AResponse: ICrossHttpResponse);
var
  nQPos, nAPos: Integer;
begin
  FStatusCode := 200;
  FQueryFields := TStringList.Create;
  FContentFields := TStringList.Create;
  FRequest := ARequest;
  FResponse := AResponse;
  FHost := GetHeader('HOST');
  FRemoteIP := ARequest.Connection.PeerAddr;
  FMethod := StringToUTF8(FRequest.Method);
  FURL := PrepareURL;
  nAPos := pos('#', FURL);
  nQPos := pos('?', FURL);
  FPathInfo := ARequest.path;
  FQueryString := ARequest.Query.Encode;
  FAnchor := '';
  FQueryFields.Text := ARequest.Query.Encode;
end;

destructor THttpApi.Destroy;
begin
  FContentFields.Free;
  FQueryFields.Free;
  inherited;
end;

function THttpApi.GetContentFields: TStrings;
begin
  if FContentFields.Count = 0 then
  begin
    if IdemPChar(PUTF8Char(StringToUTF8(Request.ContentType)), 'APPLICATION/X-WWW-FORM-URLENCODED') then
      FContentFields.Text := UTF8ToString(StringReplaceAll(TEncoding.UTF8.GetString(GetRawContent), '&', #13#10))
    else if IdemPChar(PUTF8Char(FRequest.ContentType), 'MULTIPART/FORM-DATA') then
      processMultiPartFormData;
  end;
  Result := FContentFields;
end;

function THttpApi.GetHeader(const AUpKey: RawUTF8): RawUTF8;
begin
  result := FRequest.GetHeader.Params[AUpKey];
end;

function THttpApi.GetRawContent: TBytes;
var
  vFormField: TBytes;
  i: Integer;
  vlen: UInt64;
  vstr: string;
begin
  case Request.GetBodyType of
    btNone:
      begin
        Result := nil;
      end;
    btMultiPart:
      begin
        SetLength(result, TBytesStream(Request.Body).Size);
        TBytesStream(Request.Body).position := 0;
        TBytesStream(Request.Body).Read(result[0], TBytesStream(Request.Body).Size);
      end;
    btUrlEncoded:
      begin
        result := TEncoding.UTF8.GetBytes(THttpUrlParams(Request.Body).Encode);
      end;
    btBinary:
      begin
        SetLength(result, TBytesStream(Request.Body).Size);
        TBytesStream(Request.Body).position := 0;
        TBytesStream(Request.Body).Read(result[0], TBytesStream(Request.Body).Size);
      end;
  end;
end;

function THttpApi.MethodAndPathInfo: RawUTF8;
begin
  Result := Method + ':' + PathInfo;
end;

procedure THttpApi.OutFile(const AFileName: string);
var
  ContentType: RawUTF8;
const
  HTTP_RESP_STATICFILE = '!STATICFILE';
  HEADER_CONTENT_TYPE = 'Content-Type: ';
begin
  Context.ContentType := HTTP_RESP_STATICFILE;
  ContentType := InferContentType(AFileName);
  if Length(ContentType) > 0 then
  begin
    OutHeader(HEADER_CONTENT_TYPE + ContentType);
  end;
  OutContent := AFileName;
end;

procedure THttpApi.OutHeader(const ANewHeaderAppended: RawUTF8);
begin
  if Length(ANewHeaderAppended) > 0 then
  begin
    with Context do
    begin
      Header.Decode(ANewHeaderAppended, false);
    end;
  end;
end;

procedure THttpApi.OutStream(const AStream: TStream; const AContentType: RawUTF8);
begin
  if AStream.Size > 0 then
  begin
    if not Assigned(FOutPutstream) then
    begin
      FOutPutstream := TMemoryStream.Create;
    end;
    AStream.Position := 0;
    FOutPutstream.CopyFrom(AStream, AStream.Size);
    if Length(AContentType) > 0 then
      Context.ContentType := AContentType;
  end;
end;

function THttpApi.PrepareURL: RawUTF8;
begin
  Result := StringToUTF8(FRequest.RawPathAndParams);
end;

procedure THttpApi.processMultiPartFormData;
begin

end;

procedure THttpApi.Redirect(const AURI: string);
begin
  begin
    OutHeader('Location: ' + StringToUTF8(AURI));
    FStatusCode := 302;
  end;
end;

{ TRequest }

constructor TRequest.Create(const AEnv: THttpApi);
begin
  FEnv := AEnv;
  inherited Create;
end;

function TRequest.GetDateVariable(Index: Integer): TDateTime;
begin
  Result := Now;
end;

function TRequest.GetFieldByName(const Name: WBString): WBString;
begin

end;

function TRequest.GetIntegerVariable(Index: Integer): WBInt;
begin
  if Index = cstInContentLength then
    Result := StrToIntDef(UTF8ToString(FEnv.GetHeader('CONTENT-LENGTH')), 0)
  else if Index = cstInHeaderServerPort then
    Result := 80
  else
    Result := 0;
end;

function TRequest.GetInternalPathInfo: WBString;
begin
  Result := PathInfo;
end;

function TRequest.GetInternalScriptName: WBString;
begin
  Result := '';
end;

function TRequest.GetRawContent: TBytes;
var
  AContent, AContent2: AnsiString;
  k: integer;
begin
  if ContentType.StartsWith('multipart/form-data') then
  begin
    Result := Env.GetRawContent;
  end
  else
  begin
    AContent := TIdURI.URLDecode(EncodingGetString(ContentType, Env.GetRawContent));
    if (Pos('{', AContent) > 0) and (Pos('}', AContent) > 0) then
    begin
      Result := Env.GetRawContent;
    end
    else
    begin
      k := TEncoding.UTF8.GetCharCount(BytesOf(AContent));
      if k > 0 then
        AContent2 := EncodingGetString(ContentType, BytesOf(AContent))
      else
        AContent2 := AContent;

      if AContent = AContent2 then
        Result := Env.GetRawContent
      else
      begin
        AContent := StringReplaceAll(TIdURI.URLEncode('http://api/?' + AContent2), 'http://api/?', '');
        Result := BytesOf(AContent);
      end;
    end;
  end;
end;

function TRequest.GetRemoteIP: WBString;
begin
  Result := FEnv.RemoteIP;
end;

function TRequest.GetRequest: ICrossHttpRequest;
begin
  Result := FEnv.Request;
end;

function TRequest.GetStringVariable(Index: Integer): WBString;
var
  vInContent: TBytes;
begin
  if Index = cstInHeaderMethod then
  begin
    Result := UTF8ToWBString(FEnv.Method);
  end
  else if Index = cstInHeaderProtocolVersion then
  begin
    Result := '';
  end
  else if Index = cstInHeaderURL then
  begin
    Result := UTF8ToWBString(FEnv.URL);
  end
  else if Index = cstInHeaderQuery then
  begin
    Result := UTF8ToWBString(FEnv.QueryString);
  end
  else if Index = cstInHeaderPathInfo then
  begin
    Result := UTF8ToWBString(FEnv.PathInfo);
  end
  else if Index = cstInHeaderPathTranslated then
  begin
    Result := UTF8ToWBString(FEnv.PathInfo);
  end
  else if Index = cstInHeaderCacheControl then
  begin
    Result := '';
  end
  else if Index = cstInHeaderAccept then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('ACCEPT'));
  end
  else if Index = cstInHeaderFrom then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('FROM'));
  end
  else if Index = cstInHeaderHost then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('HOST'));
  end
  else if Index = cstInHeaderReferer then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('REFERER'));
  end
  else if Index = cstInHeaderUserAgent then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('USER-AGENT'));
  end
  else if Index = cstInContentEncoding then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONTENT-ENCODING'));
  end
  else if Index = cstInContentType then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONTENT-TYPE'));
  end
  else if Index = cstInContentVersion then
  begin
    Result := '';
  end
  else if Index = cstInHeaderDerivedFrom then
  begin
    Result := '';
  end
  else if Index = cstInHeaderTitle then
  begin
    Result := '';
  end
  else if Index = cstInHeaderRemoteAddr then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('REMOTEIP'));
  end
  else if Index = cstInHeaderRemoteHost then
  begin
    Result := '';
  end
  else if Index = cstInHeaderScriptName then
  begin
    Result := '';
{$IF CompilerVersion<30.0} //Delphi 10.2 move this to function RawContent
  end
  else if Index = cstInContent then
  begin
    begin
      vInContent := GetRawContent;
      if vInContent <> nil then
        Result := TEncoding.UTF8.GetString(GetRawContent);
    end;

{$IFEND}
  end
  else if Index = cstInHeaderConnection then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONNECTION'));
  end
  else if Index = cstInHeaderCookie then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('COOKIE'));
  end
  else if Index = cstInHeaderAuthorization then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('Authorization'));
  end;
end;

function TRequest.ReadClient(var Buffer; Count: Integer): Integer;
begin
  Result := 0;
end;

function TRequest.ReadString(Count: Integer): WBString;
begin
  Result := '';
end;

function TRequest.TranslateURI(const URI: string): string;
begin
  Result := '';
end;

function TRequest.WriteClient(var Buffer; Count: Integer): Integer;
begin
  Result := 0;
end;

function TRequest.WriteHeaders(StatusCode: Integer; const ReasonString, Headers: WBString): Boolean;
begin
  Result := False;
end;

function TRequest.WriteString(const AString: WBString): Boolean;
begin
  Result := False;
end;

{ TResponse }

constructor TResponse.Create(HTTPRequest: TRequest);
begin
  inherited Create(HTTPRequest);
  FSent := False;
end;

function TResponse.GetContent: string;
begin
  Result := UTF8ToWBString(Env.OutContent);
end;

function TResponse.GetDateVariable(Index: Integer): TDateTime;
begin
  Result := Now;
end;

function TResponse.GetEnv: THttpApi;
begin
  Result := TRequest(FHTTPRequest).Env;
end;

function TResponse.GetIntegerVariable(Index: Integer): WBInt;
begin
  Result := 0;
end;

function TResponse.GetLogMessage: string;
begin
  Result := '';
end;

function TResponse.GetResponse: ICrossHttpResponse;
begin
  Result := Env.Context;
end;

function TResponse.GetStatusCode: Integer;
begin
  Result := Env.StatusCode;
end;

function TResponse.GetStringVariable(Index: Integer): string;
begin
  Result := '';
  if Index = cstOutHeaderContentType then
    Result := UTF8ToWBString(Response.ContentType);
end;

procedure TResponse.OutCookiesAndCustomHeaders;
var
  i: Integer;
begin
  for i := 0 to Cookies.Count - 1 do
    Env.OutHeader(StringToUTF8('Set-Cookie: ' + Cookies[i].HeaderValue));
  for i := 0 to CustomHeaders.Count - 1 do
    Env.OutHeader(StringToUTF8(CustomHeaders.Names[i] + ': ' + CustomHeaders.Values[CustomHeaders.Names[i]]));
end;

procedure TResponse.SendRedirect(const URI: WBString);
begin
  Env.Redirect(URI);
  Env.OutContent := ' ';
  FSent := True;

end;

procedure TResponse.SendResponse;
var
  vSendTream: TStream;
begin
  OutCookiesAndCustomHeaders;
  Response.StatusCode := Env.StatusCode;
  if Length(Env.OutContent) > 0 then
  begin
    Response.Send(Env.OutContent);
  end;

  if Assigned(env.OutPutstream) then
  begin
    vSendTream := Env.OutPutstream;
    vSendTream.Position := 0;
    Response.Send(vSendTream,
      procedure(AConnection: ICrossConnection; ASuccess: Boolean)
      begin
        vSendTream.Free;
      end);
  end;
  FSent := True;
end;

procedure TResponse.SendStream(AStream: TStream);
begin
  Env.OutStream(AStream);
end;

function TResponse.Sent: Boolean;
begin
  Result := FSent;
end;

procedure TResponse.SetContent(const Value: string);
begin

  Env.OutContent := WBStringToUTF8(Value);
end;

procedure TResponse.SetContentStream(Value: TStream);
begin
  inherited;
  SendStream(Value);
end;

procedure TResponse.SetDateVariable(Index: Integer; const Value: TDateTime);
begin
  inherited;

end;

procedure TResponse.SetIntegerVariable(Index: Integer; Value: WBInt);
begin
  inherited;

end;

procedure TResponse.SetLogMessage(const Value: string);
begin
  inherited;

end;

procedure TResponse.SetStatusCode(Value: Integer);
begin
  inherited;
  Env.StatusCode := Value;
end;

procedure TResponse.SetStringVariable(Index: Integer; const Value: string);
begin
  if Index = cstOutHeaderContentType then
    Response.ContentType := Value;
end;

end.

