{ *************************************************************************** }
{  SynWebReqRes.pas is the 2nd file of SynBroker Project                      }
{  by c5soft@189.cn  Version 0.9.2.1  2018-6-7                                }
{ *************************************************************************** }

unit CrossWebReqRes;

interface

uses
  SysUtils, Classes, HTTPApp, CrossCommon, CrossWebEnv, IdURI,
  Net.CrossHttpServer, Net.CrossHttpParams, Net.CrossSocket.Base;

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

  TCrossWebRequest = class(TWebRequest)
  private
    function GetRequest: ICrossHttpRequest;
  protected
    FEnv: TCrossWebEnv;
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
    property Request: ICrossHttpRequest read GetRequest;
    property Env: TCrossWebEnv read FEnv;
    constructor Create(const AEnv: TCrossWebEnv);
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

  TCrossWebResponse = class(TWebResponse)
  private
    FSent: Boolean;
    function GetResponse: ICrossHttpResponse;
    function GetEnv: TCrossWebEnv;
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
    property Response: ICrossHttpResponse read GetResponse;
    property Env: TCrossWebEnv read GetEnv;
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
{ TCrossWebRequest }

constructor TCrossWebRequest.Create(const AEnv: TCrossWebEnv);
begin
  FEnv := AEnv;
  inherited Create;
end;

function TCrossWebRequest.GetDateVariable(Index: Integer): TDateTime;
begin
  Result := Now;
end;

function TCrossWebRequest.GetFieldByName(const Name: WBString): WBString;
begin
  Result := '';
end;

function TCrossWebRequest.GetIntegerVariable(Index: Integer): Integer;
begin
  if Index = cstInContentLength then
    Result := StrToIntDef(UTF8ToString(FEnv.GetHeader('CONTENT-LENGTH')), 0)
  else if Index = cstInHeaderServerPort then
    Result := 80
  else
    Result := 0;
end;

function TCrossWebRequest.GetInternalPathInfo: WBString;
begin
  Result := PathInfo;
end;

function TCrossWebRequest.GetInternalScriptName: WBString;
begin
  Result := '';
end;

{$IFDEF UNICODE}

function TCrossWebRequest.GetRemoteIP: string;
begin
  //Result := UTF8ToString(FEnv.GetHeader('REMOTEIP'));
  Result := FEnv.RemoteIP;
end;
{$ENDIF}

{$IF CompilerVersion>=30.0}

function TCrossWebRequest.GetRawContent: TBytes;
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
{$IFEND}

function TCrossWebRequest.GetStringVariable(Index: Integer): WBString;
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

function TCrossWebRequest.ReadClient(var Buffer; Count: Integer): Integer;
begin
  Result := 0;
end;

function TCrossWebRequest.ReadString(Count: Integer): WBString;
begin
  Result := '';
end;

function TCrossWebRequest.TranslateURI(const URI: string): string;
begin
  Result := '';
end;

function TCrossWebRequest.WriteClient(var Buffer; Count: Integer): Integer;
begin
  Result := 0;
end;

function TCrossWebRequest.WriteHeaders(StatusCode: Integer; const ReasonString, Headers: WBString): Boolean;
begin
  Result := False;
end;

function TCrossWebRequest.WriteString(const AString: WBString): Boolean;
begin
  Result := False;
end;

function TCrossWebRequest.GetRequest: ICrossHttpRequest;
begin
  Result := FEnv.Request;
end;

{ TCrossWebResponse }

constructor TCrossWebResponse.Create(HTTPRequest: TWebRequest);
begin
  inherited Create(HTTPRequest);
  FSent := False;
end;

function TCrossWebResponse.GetContent: WBString;
begin
  Result := UTF8ToWBString(Env.OutContent);
end;

function TCrossWebResponse.GetResponse: ICrossHttpResponse;
begin
  Result := Env.Context;
end;

function TCrossWebResponse.GetDateVariable(Index: Integer): TDateTime;
begin
  Result := Now;
end;

function TCrossWebResponse.GetEnv: TCrossWebEnv;
begin
  Result := TCrossWebRequest(FHTTPRequest).Env;
end;

function TCrossWebResponse.GetIntegerVariable(Index: Integer): Integer;
begin
  Result := 0;
end;

function TCrossWebResponse.GetLogMessage: string;
begin
  Result := '';
end;

function TCrossWebResponse.GetStatusCode: Integer;
begin
  Result := Env.StatusCode;
end;

function TCrossWebResponse.GetStringVariable(Index: Integer): WBString;
begin
  Result := '';
  if Index = cstOutHeaderContentType then
    Result := UTF8ToWBString(Response.ContentType);
end;

procedure TCrossWebResponse.OutCookiesAndCustomHeaders;
var
  i: Integer;
begin
  for i := 0 to Cookies.Count - 1 do
    Env.OutHeader(StringToUTF8('Set-Cookie: ' + Cookies[i].HeaderValue));
  for i := 0 to CustomHeaders.Count - 1 do
    Env.OutHeader(StringToUTF8(CustomHeaders.Names[i] + ': ' + CustomHeaders.Values[CustomHeaders.Names[i]]));
end;

procedure TCrossWebResponse.SendRedirect(const URI: WBString);
begin
  Env.Redirect(URI);
  Env.OutContent := ' ';
  FSent := True;
end;

procedure TCrossWebResponse.SendResponse;
var
  vSendbyte: TBytes;
  vSendType: string;
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
//      vSendTream.CopyFrom(Env.OutPutstream,Env.OutPutstream.Size);
    Response.Send(vSendTream,
      procedure(AConnection: ICrossConnection; ASuccess: Boolean)
      begin
        vSendTream.Free;
      end);
  end;
  FSent := True;
end;

procedure TCrossWebResponse.SendStream(AStream: TStream);
begin
  Env.OutStream(AStream);
end;

function TCrossWebResponse.Sent: Boolean;
begin
  Result := FSent;
end;

procedure TCrossWebResponse.SetContent(const Value: WBString);
begin
  Env.OutContent := WBStringToUTF8(Value);
end;

procedure TCrossWebResponse.SetContentStream(Value: TStream);
begin
  inherited;
  SendStream(Value);
end;

procedure TCrossWebResponse.SetDateVariable(Index: Integer; const Value: TDateTime);
begin

end;

procedure TCrossWebResponse.SetIntegerVariable(Index, Value: Integer);
begin

end;

procedure TCrossWebResponse.SetLogMessage(const Value: string);
begin

end;

procedure TCrossWebResponse.SetStatusCode(Value: Integer);
begin
  Env.StatusCode := Value;
end;

procedure TCrossWebResponse.SetStringVariable(Index: Integer; const Value: WBString);
begin
  if Index = cstOutHeaderContentType then
    Response.ContentType := Value;
end;

initialization
  //RegisterContentParser(TContentParser);



end.

