{ *************************************************************************** }
{  SynWebReqRes.pas is the 2nd file of SynBroker Project                      }
{  by c5soft@189.cn  Version 0.9.2.1  2018-6-7                                }
{ *************************************************************************** }

unit SynWebReqRes;

interface

uses SysUtils, Classes, HTTPApp, SynCommons, SynCrtSock, SynWebEnv;

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
type
{$IF (CompilerVersion<20.0) OR (CompilerVersion>=30.0) }
  WBString = string;
{$ELSE}
  WBString = AnsiString;
{$IFEND}

  TSynWebRequest = class(TWebRequest)
  private
    function GetContext: THttpServerRequest;
  protected
    FEnv: TSynWebEnv;
    function GetStringVariable(Index: Integer): WBString; override;
    function GetDateVariable(Index: Integer): TDateTime; override;
    function GetIntegerVariable(Index: Integer): Integer; override;
    function GetInternalPathInfo: WBString; override;
    function GetInternalScriptName: WBString; override;
{$IFDEF UNICODE}
    function GetRemoteIP: string; override;
{$ENDIF}
{$IF CompilerVersion>=30.0}
    function GetRawContent: TBytes; override;
{$IFEND}
  public
    property Context: THttpServerRequest read GetContext;
    property Env: TSynWebEnv read FEnv;
    constructor Create(const AEnv: TSynWebEnv);
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
    function WriteHeaders(StatusCode: Integer;
      const ReasonString, Headers: WBString): Boolean; override;
    function GetFieldByName(const Name: WBString): WBString; override;
  end;

  TSynWebResponse = class(TWebResponse)
  private
    FSent: Boolean;
    function GetContext: THttpServerRequest;
    function GetEnv: TSynWebEnv;
  protected
    function GetStringVariable(Index: Integer): WBString; override;
    procedure SetStringVariable(Index: Integer; const Value: WBString); override;
    function GetDateVariable(Index: Integer): TDateTime; override;
    procedure SetDateVariable(Index: Integer; const Value: TDateTime); override;
    function GetIntegerVariable(Index: Integer): Integer; override;
    procedure SetIntegerVariable(Index: Integer; Value: Integer); override;
    function GetContent: WBString; override;
    procedure SetContent(const Value: WBString); override;
    procedure SetContentStream(Value: TStream); override;
    function GetStatusCode: Integer; override;
    procedure SetStatusCode(Value: Integer); override;
    function GetLogMessage: string; override;
    procedure SetLogMessage(const Value: string); override;
    procedure OutCookiesAndCustomHeaders;
  public
    constructor Create(HTTPRequest: TWebRequest);
    property Context: THttpServerRequest read GetContext;
    property Env: TSynWebEnv read GetEnv;
    procedure SendResponse; override;
    procedure SendRedirect(const URI: WBString); override;
    procedure SendStream(AStream: TStream); override;
    function Sent: Boolean; override;
  end;

  // Ver 0.0.0.2 +
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
{ TSynWebRequest }

constructor TSynWebRequest.Create(const AEnv: TSynWebEnv);
begin
  FEnv := AEnv;
  inherited Create;
end;

function TSynWebRequest.GetDateVariable(Index: Integer): TDateTime;
begin
  Result := Now;
end;

function TSynWebRequest.GetFieldByName(const Name: WBString): WBString;
begin
  Result := '';
end;

function TSynWebRequest.GetIntegerVariable(Index: Integer): Integer;
begin
  if Index = cstInContentLength then
    Result := StrToIntDef(UTF8ToString(FEnv.GetHeader('CONTENT-LENGTH:')), 0)
  else if Index = cstInHeaderServerPort then Result := 80
  else Result := 0;
end;

function TSynWebRequest.GetInternalPathInfo: WBString;
begin
  Result := PathInfo;
end;

function TSynWebRequest.GetInternalScriptName: WBString;
begin
  Result := '';
end;

{$IFDEF UNICODE}

function TSynWebRequest.GetRemoteIP: string;
begin
  Result := UTF8ToString(FEnv.GetHeader('REMOTEIP:'));
end;
{$ENDIF}

{$IF CompilerVersion>=30.0}

function TSynWebRequest.GetRawContent: TBytes;
begin
  RawByteStringToBytes(Context.InContent, Result);
end;
{$IFEND}

function TSynWebRequest.GetStringVariable(Index: Integer): WBString;
begin
  if Index = cstInHeaderMethod then begin
    Result := UTF8ToWBString(FEnv.Method);
  end else if Index = cstInHeaderProtocolVersion then begin
    Result := '';
  end else if Index = cstInHeaderURL then begin
    Result := UTF8ToWBString(FEnv.URL);
  end else if Index = cstInHeaderQuery then begin
    Result := UTF8ToWBString(URLDecode(FEnv.QueryString));
  end else if Index = cstInHeaderPathInfo then begin
    Result := UTF8ToWBString(FEnv.PathInfo);
  end else if Index = cstInHeaderPathTranslated then begin
    Result := UTF8ToWBString(FEnv.PathInfo);
  end else if Index = cstInHeaderCacheControl then begin
    Result := '';
  end else if Index = cstInHeaderAccept then begin
    Result := UTF8ToWBString(FEnv.GetHeader('ACCEPT:'));
  end else if Index = cstInHeaderFrom then begin
    Result := UTF8ToWBString(FEnv.GetHeader('FROM:'));
  end else if Index = cstInHeaderHost then begin
    Result := UTF8ToWBString(FEnv.GetHeader('HOST:'));
  end else if Index = cstInHeaderReferer then begin
    Result := UTF8ToWBString(FEnv.GetHeader('REFERER:'));
  end else if Index = cstInHeaderUserAgent then begin
    Result := UTF8ToWBString(FEnv.GetHeader('USER-AGENT:'));
  end else if Index = cstInContentEncoding then begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONTENT-ENCODING:'));
  end else if Index = cstInContentType then begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONTENT-TYPE:'));
  end else if Index = cstInContentVersion then begin
    Result := '';
  end else if Index = cstInHeaderDerivedFrom then begin
    Result := '';
  end else if Index = cstInHeaderTitle then begin
    Result := '';
  end else if Index = cstInHeaderRemoteAddr then begin
    Result := UTF8ToWBString(FEnv.GetHeader('REMOTEIP:'));
  end else if Index = cstInHeaderRemoteHost then begin
    Result := '';
  end else if Index = cstInHeaderScriptName then begin
    Result := '';
{$IF CompilerVersion<30.0} //Delphi 10.2 move this to function RawContent
  end else if Index = cstInContent then begin
    Result := Context.InContent;
{$IFEND}
  end else if Index = cstInHeaderConnection then begin
    Result := UTF8ToWBString(FEnv.GetHeader('CONNECTION:'));
  end else if Index = cstInHeaderCookie then begin
    Result := UTF8ToWBString(URLDecode(FEnv.GetHeader('COOKIE:')));
  end else if Index = cstInHeaderAuthorization then begin
    Result := '';
  end;
end;

function TSynWebRequest.ReadClient(var Buffer; Count: Integer): Integer;
begin
  Result := 0;
end;

function TSynWebRequest.ReadString(Count: Integer): WBString;
begin
  Result := '';
end;

function TSynWebRequest.TranslateURI(const URI: string): string;
begin
  Result := '';
end;

function TSynWebRequest.WriteClient(var Buffer; Count: Integer): Integer;
begin
  Result := 0;
end;

function TSynWebRequest.WriteHeaders(StatusCode: Integer;
  const ReasonString, Headers: WBString): Boolean;
begin
  Result := False;
end;

function TSynWebRequest.WriteString(const AString: WBString): Boolean;
begin
  Result := False;
end;

function TSynWebRequest.GetContext: THttpServerRequest;
begin
  Result := FEnv.Context;
end;

{ TSynWebResponse }

constructor TSynWebResponse.Create(HTTPRequest: TWebRequest);
begin
  Inherited Create(HTTPRequest);
  FSent:=False;
end;

function TSynWebResponse.GetContent: WBString;
begin
  Result := UTF8ToWBString(Context.OutContent);
end;

function TSynWebResponse.GetContext: THttpServerRequest;
begin
  Result := TSynWebRequest(FHTTPRequest).Context;
end;

function TSynWebResponse.GetDateVariable(Index: Integer): TDateTime;
begin
  Result := Now;
end;

function TSynWebResponse.GetEnv: TSynWebEnv;
begin
  Result := TSynWebRequest(FHTTPRequest).Env;
end;

function TSynWebResponse.GetIntegerVariable(Index: Integer): Integer;
begin
  Result := 0;
end;

function TSynWebResponse.GetLogMessage: string;
begin
  Result := '';
end;

function TSynWebResponse.GetStatusCode: Integer;
begin
  Result := Env.StatusCode;
end;

function TSynWebResponse.GetStringVariable(Index: Integer): WBString;
begin
  Result := '';
  if Index = cstOutHeaderContentType then
    Result := UTF8ToWBString(Context.OutContentType);
end;

procedure TSynWebResponse.OutCookiesAndCustomHeaders;
var
  i: Integer;
begin
  for i := 0 to Cookies.Count - 1 do
    Env.OutHeader(StringToUTF8('Set-Cookie: ' + Cookies[i].HeaderValue));
  for i := 0 to CustomHeaders.Count - 1 do
    Env.OutHeader(StringToUTF8(CustomHeaders.Names[i] + ': ' + CustomHeaders.Values[CustomHeaders.Names[i]]));
end;

procedure TSynWebResponse.SendRedirect(const URI: WBString);
begin
  Env.Redirect(URI);
  Env.Context.OutContent:=' ';
  FSent := True;
end;

procedure TSynWebResponse.SendResponse;
begin
  OutCookiesAndCustomHeaders;
  FSent := True;
end;

procedure TSynWebResponse.SendStream(AStream: TStream);
begin
  Env.OutStream(AStream);
end;

function TSynWebResponse.Sent: Boolean;
begin
  Result := FSent;
end;

procedure TSynWebResponse.SetContent(const Value: WBString);
begin
  Context.OutContent := WBStringToUTF8(Value);
end;

procedure TSynWebResponse.SetContentStream(Value: TStream);
begin
  inherited;
  SendStream(Value);
end;

procedure TSynWebResponse.SetDateVariable(Index: Integer;
  const Value: TDateTime);
begin

end;

procedure TSynWebResponse.SetIntegerVariable(Index, Value: Integer);
begin

end;

procedure TSynWebResponse.SetLogMessage(const Value: string);
begin

end;

procedure TSynWebResponse.SetStatusCode(Value: Integer);
begin
  Env.StatusCode := Value;
end;

procedure TSynWebResponse.SetStringVariable(Index: Integer;
  const Value: WBString);
begin
  if Index = cstOutHeaderContentType then
    Context.OutContentType := WBStringToUTF8(Value);
end;

initialization
  //RegisterContentParser(TContentParser);

end.

