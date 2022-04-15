unit MVC.HttpMmt;

interface

uses
  System.DateUtils, SysUtils, Classes, IniFiles, Contnrs, SynCommons, SynCrtSock,
  Web.WebReq, Web.HTTPApp, MVC.Config, IdURI, MVC.Route, SynZip, MVC.LogUnit;

const
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
  THttpApi = class
  protected
    FContext: THttpServerRequest;
    FStatusCode: Integer;
    FMethod: string;
    FQueryString: string;
    FAnchor: string;
    FQueryFields: TStrings;
    FContentFields: TStrings;
    FRemoteIP: string;
    FPathInfo: string;
    FURL: string;
    FHost: string;
    function GetContentFields: TStrings;
    procedure processMultiPartFormData; virtual;
  public
    property Context: THttpServerRequest read FContext;
    property StatusCode: Integer read FStatusCode write FStatusCode;
    property Host: string read FHost;
    property Method: string read FMethod;
    property URL: string read FURL;
    property PathInfo: string read FPathInfo;
    property QueryString: string read FQueryString;
    property Anchor: string read FAnchor;
    property RemoteIP: string read FRemoteIP;
    property QueryFields: TStrings read FQueryFields;
    property ContentFields: TStrings read GetContentFields;
    //
    procedure OutHeader(const ANewHeaderAppended: RawUTF8);
    procedure OutStream(const AStream: TStream; const AContentType: RawUTF8 = '');
    procedure Redirect(const AURI: string);
    function GetHeader(const AUpKey: RawUTF8; const ASource: RawUTF8 = ''; const Sep: AnsiChar = #13): RawUTF8;
    constructor Create(const vContext: THttpServerRequest);
    destructor Destroy; override;
  end;

  TRequest = class(TWebRequest)
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
    function GetContext: THttpServerRequest;
    function GetRemoteIP: WBString; override;
    function GetRawContent: TBytes; override;
  public
    property Context: THttpServerRequest read GetContext;
    function WriteHeaders(StatusCode: Integer; const ReasonString, Headers: WBString): Boolean; override;
    property Env: THttpApi read FEnv;
    constructor Create(const AEnv: THttpApi);
  end;

  TResponse = class(TWebResponse)
  private
    FSent: Boolean;
    function GetContext: THttpServerRequest;
    function GetEnv: THttpApi;

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
    property Context: THttpServerRequest read GetContext;
    property Env: THttpApi read GetEnv;
    procedure SendResponse; override;
    procedure SendRedirect(const URI: string); override;
    procedure SendStream(AStream: TStream); override;
    function Sent: Boolean; override;
  end;

  THTTPServer = class
  public
    HServer: THttpApiServer;
    Action: Boolean;
    procedure Start();
    procedure Stop();
    function Process(AContext: THttpServerRequest): cardinal;
    //
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
{ THttpServer }

constructor THTTPServer.Create;
begin
  if not Assigned(HServer) then
  begin
    HServer := THttpApiServer.Create(False);
    HServer.OnRequest := Process;
  end;

end;

destructor THTTPServer.Destroy;
begin
  if Assigned(HServer) then
  begin
 //   HServer.Shutdown;
    HServer.Free;
  end;
  inherited;
end;

function THTTPServer.Process(AContext: THttpServerRequest): cardinal;
var
  httpApi: THttpApi;
  request: TRequest;
  response: TResponse;
begin
  httpApi := THttpApi.Create(AContext);
  request := TRequest.Create(httpApi);
  response := TResponse.Create(request);
  try
    OpenRoute(request, response);
    Result := response.StatusCode;
  finally
    request.Free;
    response.Free;
    httpApi.Free;
  end;

end;

procedure THTTPServer.Start;
var
  compress: string;
begin
  try
    compress := Config.Compress;
    if UpperCase(compress) = UpperCase('deflate') then
      HServer.RegisterCompress(CompressDeflate)
    else if UpperCase(compress) = UpperCase('gzip') then
      HServer.RegisterCompress(CompressGZip);

    HServer.AddUrl('', Config.Port, False, '+', false);
    HServer.HTTPQueueLength := Config.HTTPQueueLength;
    HServer.Clone(Config.ThreadCount);   //ChildThreadCount启动http监听线程
    Action := true;
    log('服务启动');
  except
    on e: Exception do
    begin
      log('服务启动失败:' + e.Message);
      {$IFDEF CONSOLE}
      Writeln('服务启动失败:' + e.Message);
      {$ENDIF}
    end;
  end;
end;

procedure THTTPServer.Stop;
begin
  HServer.RemoveUrl('', config.Port, False, '+');
  log('服务停止');
end;

{ THttpApi }

constructor THttpApi.Create(const vContext: THttpServerRequest);
var
  nQPos, nAPos: Integer;
begin
  FStatusCode := 200;
  FContext := vContext;
  FQueryFields := TStringList.Create;
  FContentFields := TStringList.Create;
  FHost := GetHeader('HOST:');
  FRemoteIP := UTF8ToString(GetHeader('REMOTEIP:'));
  FMethod := FContext.Method;
  FURL := FContext.URL;
  nAPos := Pos('#', FURL);
  nQPos := Pos('?', FURL);
  if nQPos > 0 then
  begin
    FPathInfo := copy(FURL, 1, nQPos - 1);
    if nAPos > nQPos then
    begin
      FQueryString := copy(FURL, nQPos + 1, nAPos - nQPos - 1);
      FAnchor := copy(FURL, nAPos + 1, Length(FURL) - nAPos);
    end
    else
    begin
      FQueryString := copy(FURL, nQPos + 1, Length(FURL) - nQPos);
      FAnchor := '';
    end;
  end
  else
  begin
    FQueryString := '';
    if nAPos > 0 then
    begin
      FPathInfo := copy(FURL, 1, nAPos - 1);
      FAnchor := copy(FURL, nAPos + 1, Length(FURL) - nAPos);
    end
    else
    begin
      FPathInfo := FURL;
      FAnchor := '';
    end;
  end;
  FQueryFields.Text := UTF8ToString(StringReplaceAll(URLDecode(FQueryString), '&', #13#10));
end;

destructor THttpApi.Destroy;
begin
  FQueryFields.Free;
  FContentFields.Free;
  inherited;
end;

function THttpApi.GetContentFields: TStrings;
begin
  if FContentFields.Count = 0 then
  begin
    if IdemPChar(PUTF8Char(FContext.InContentType), 'APPLICATION/X-WWW-FORM-URLENCODED') then
      FContentFields.Text := UTF8ToString(StringReplaceAll(URLDecode(FContext.InContent), '&', #13#10))
    else if IdemPChar(PUTF8Char(Context.InContentType), 'MULTIPART/FORM-DATA') then
      processMultiPartFormData;
  end;
  Result := FContentFields;
end;

function THttpApi.GetHeader(const AUpKey, ASource: RawUTF8; const Sep: AnsiChar): RawUTF8;
var
  text: string;
  headls: TStringList;
  key: string;
begin
  key := AUpKey;
  key := key.Replace(':', '');
  headls := TStringList.Create;
  try
    text := FContext.InHeaders;
    headls.Text := text.Replace(': ', '=');
    Result := headls.Values[key];
  finally
    headls.Free;
  end;
end;

procedure THttpApi.OutHeader(const ANewHeaderAppended: RawUTF8);
begin
  if Length(ANewHeaderAppended) > 0 then
  begin
    with FContext do
    begin
      if Length(OutCustomHeaders) > 0 then
        OutCustomHeaders := OutCustomHeaders + #13#10;
      OutCustomHeaders := OutCustomHeaders + ANewHeaderAppended;
    end;
  end;
end;

procedure THttpApi.OutStream(const AStream: TStream; const AContentType: RawUTF8);
var
  Buffer: SockString;
begin
  SetLength(Buffer, AStream.Size);
  AStream.Read(Buffer[1], AStream.Size);
  Context.OutContent := Buffer;
  if Length(AContentType) > 0 then
    Context.OutContentType := AContentType;
end;

procedure THttpApi.processMultiPartFormData;
begin

end;

procedure THttpApi.Redirect(const AURI: string);
begin
  OutHeader('Location: ' + AURI);
  FStatusCode := 302;
end;

{ TRequest }

constructor TRequest.Create(const AEnv: THttpApi);
begin
  FEnv := AEnv;
  inherited Create;
end;

function TRequest.GetContext: THttpServerRequest;
begin
  Result := FEnv.Context;
end;

function TRequest.GetDateVariable(Index: Integer): TDateTime;
begin
  Result := Now;
end;

function TRequest.GetIntegerVariable(Index: Integer): WBInt;
begin
  if Index = cstInContentLength then
    Result := StrToIntDef(UTF8ToString(FEnv.GetHeader('CONTENT-LENGTH:')), 0)
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
  AContent: AnsiString;
  k: Integer;
begin
  if ContentType.StartsWith('multipart/form-data') then
  begin
    RawByteStringToBytes(Context.InContent, Result);
  end
  else
  begin
    if (Pos('{', Context.InContent) > 0) and (Pos('}', Context.InContent) > 0) then
    begin
      AContent := Context.InContent;
    end
    else
    begin
      k := TEncoding.UTF8.GetCharCount(BytesOf(Context.InContent));
      if (k > 0) then
      begin
        AContent := EncodingGetString(ContentType, BytesOf(Context.InContent));
        if (Context.InContent <> AContent) then
          AContent := StringReplaceAll(TIdURI.URLEncode('http://api/?' + AContent), 'http://api/?', '');
      end
      else
        AContent := Context.InContent;
    end;
    RawByteStringToBytes(AContent, Result);
  end;
end;

function TRequest.GetRemoteIP: WBString;
begin

  Result := FEnv.RemoteIP;
end;

function TRequest.GetStringVariable(Index: Integer): WBString;
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
    Result := UTF8ToWBString(FEnv.GetHeader('ACCEPT:'));
  end
  else if Index = cstInHeaderFrom then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('FROM:'));
  end
  else if Index = cstInHeaderHost then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('HOST:'));
  end
  else if Index = cstInHeaderReferer then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('REFERER:'));
  end
  else if Index = cstInHeaderUserAgent then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('USER-AGENT:'));
  end
  else if Index = cstInContentEncoding then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONTENT-ENCODING:'));
  end
  else if Index = cstInContentType then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONTENT-TYPE:'));
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
    Result := UTF8ToWBString(FEnv.GetHeader('REMOTEIP:'));
  end
  else if Index = cstInHeaderRemoteHost then
  begin
    Result := '';
  end
  else if Index = cstInHeaderScriptName then
  begin
    Result := '';
  end
  else if Index = cstInHeaderConnection then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONNECTION:'));
  end
  else if Index = cstInHeaderCookie then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('COOKIE:'));
  end
  else if Index = cstInHeaderAuthorization then
  begin
    Result := UTF8ToWBString(FEnv.GetHeader('Authorization:'));
  end;
end;

function TRequest.WriteHeaders(StatusCode: Integer; const ReasonString, Headers: WBString): Boolean;
begin
  Result := False;
end;

{ TResponse }

constructor TResponse.Create(HTTPRequest: TRequest);
begin
  inherited Create(HTTPRequest);
//  FHTTPRequest:=HTTPRequest;
  FSent := False;
end;

function TResponse.GetContent: string;
begin
  Result := UTF8ToWBString(Context.OutContent);
end;

function TResponse.GetContext: THttpServerRequest;
begin
  Result := TRequest(FHTTPRequest).Context;
end;

function TResponse.GetDateVariable(Index: Integer): TDateTime;
begin
  Result := Now;
end;

function TResponse.GetEnv: THttpApi;
begin
  Result := TRequest(FHTTPRequest).Env
end;

function TResponse.GetIntegerVariable(Index: Integer): WBInt;
begin
  Result := 0;
end;

function TResponse.GetLogMessage: string;
begin
  Result := '';
end;

function TResponse.GetStatusCode: Integer;
begin
  Result := Env.StatusCode;
end;

function TResponse.GetStringVariable(Index: Integer): string;
begin
  Result := '';
  if Index = cstOutHeaderContentType then
    Result := UTF8ToWBString(Context.OutContentType);
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

procedure TResponse.SendRedirect(const URI: string);
begin
  Env.Redirect(URI);
  FSent := True;
end;

procedure TResponse.SendResponse;
begin
  OutCookiesAndCustomHeaders;
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
  Context.OutContent := WBStringToUTF8(Value);

end;

procedure TResponse.SetContentStream(Value: TStream);
begin
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
  Env.StatusCode := Value;

end;

procedure TResponse.SetStringVariable(Index: Integer; const Value: string);
begin
  if Index = cstOutHeaderContentType then
    Context.OutContentType := WBStringToUTF8(Value);

end;

end.

