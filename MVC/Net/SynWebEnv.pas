{ *************************************************************************** }
{ SynWebEnv.pas is the 1st file of SynBroker Project                          }
{ by c5soft@189.cn  Version 0.9.2.0  2018-6-7                                 }
{ *************************************************************************** }
unit SynWebEnv;

interface

uses Classes, SysUtils, SynCommons, SynCrtSock;
type
  TSynWebEnv = class
  protected
    FHost, FMethod, FURL, FPathInfo, FQueryString, FAnchor: RawUTF8;
    FSSL: Boolean;
    FStatusCode: Integer;
    FRemoteIP: string;
    FContext: THttpServerRequest;
    FQueryFields: TStrings;
    FContentFields: TStrings;
    function PrepareURL: RawUTF8; virtual;
    function GetContentFields: TStrings;
    procedure processMultiPartFormData; virtual;
  public
    property StatusCode: Integer read FStatusCode write FStatusCode;
    property Context: THttpServerRequest read FContext;
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
    function GetHeader(const AUpKey: RawUTF8; const ASource: RawUTF8 = ''; const Sep: AnsiChar = #13): RawUTF8;
    constructor Create(const AContext: THttpServerRequest);
    destructor Destroy; override;
    function MethodAndPathInfo: RawUTF8;
    procedure OutStream(const AStream: TStream; const AContentType: RawUTF8 = '');
    procedure OutFile(const AFileName: string);
    procedure OutHeader(const ANewHeaderAppended: RawUTF8);
    procedure OutJSon(const AOutput: PDocVariantData); overload;
    procedure OutJSon(const AOutput: RawUTF8); overload;
{$IFDEF UNICODE}
    procedure Redirect(const AURI: string); overload;
    procedure Redirect(const AURI: RawUTF8); overload;
    procedure OutHtml(const AOutput: RawUTF8); overload;
    procedure OutHtml(const AOutput: string); overload;
    procedure OutXML(const AOutput: RawUTF8); overload;
    procedure OutXML(const AOutput: string); overload;
{$ELSE}
    procedure Redirect(const AURI: string);
    procedure OutHtml(const AOutput: string);
    procedure OutXML(const AOutput: string);
{$ENDIF}
  end;

  TDispatchAction = function(const AEnv: TSynWebEnv): Boolean;

procedure RouteMap(const Method, PathInfo: RawUTF8; const Action: TDispatchAction);
function RouteDispatch(const AEnv: TSynWebEnv; AMethodAndPathInfo: RawUTF8 = ''): Boolean;

implementation

type
  TRouteMap = record
    MethodAndPathInfo: RawUTF8;
    Action: TDispatchAction;
  end;

var
  RouteMapList: array of TRouteMap;

procedure RouteMap(const Method, PathInfo: RawUTF8; const Action: TDispatchAction);
var
  nLen: Integer;
begin
  nLen := Length(RouteMapList);
  Inc(nLen);
  SetLength(RouteMapList, nLen);
  Dec(nLen);
  RouteMapList[nLen].MethodAndPathInfo := UpperCase(Method + ':' + PathInfo);
  RouteMapList[nLen].Action := Action;
end;

function RouteDispatch(const AEnv: TSynWebEnv; AMethodAndPathInfo: RawUTF8 = ''): Boolean;
var
  i: Integer;
  rm: TRouteMap;
  cScheme: RawUTF8;
  bFound: Boolean;
begin
  Result := False;
  if AMethodAndPathInfo = '' then AMethodAndPathInfo := PUTF8Char(AEnv.MethodAndPathInfo);
  for i := Length(RouteMapList) - 1 downto 0 do begin
    rm := RouteMapList[i];
    if AEnv.SSL then cScheme := 'HTTPS ' else cScheme := 'HTTP ';
    bFound := IdemPChar(PUTF8Char(cScheme + AMethodAndPathInfo), PAnsiChar(rm.MethodAndPathInfo));
    if not bFound then begin
      bFound := IdemPChar(PUTF8Char(AMethodAndPathInfo), PAnsiChar(rm.MethodAndPathInfo));
    end;
    if bFound then begin
      Result := rm.Action(AEnv);
      break;
    end;
  end;
end;

{ TSynWebEnv }

function InferContentType(const AFileName: string): RawUTF8;
var
  cExt: string;
begin
  Result := '';
  cExt := SysUtils.UpperCase(ExtractFileExt(AFileName));
  if (cExt = '.HTML') or (cExt = '.HTM') then Result := HTML_CONTENT_TYPE
  else if cExt = '.JPG' then Result := JPEG_CONTENT_TYPE
  else if cExt = '.PNG' then Result := 'image/png'
  else if cExt = '.GIF' then Result := 'image/gif'
  else if cExt = '.ICO' then Result := 'image/x-icon'
  else if cExt = '.JS' then Result := 'application/x-javascript'
  else if cExt = '.CSS' then Result := 'text/css'
  else Result := 'application/octet-stream';
end;

function TSynWebEnv.GetContentFields: TStrings;
begin
  if FContentFields.Count = 0 then begin
    if IdemPChar(PUTF8Char(FContext.InContentType), 'APPLICATION/X-WWW-FORM-URLENCODED') then
      FContentFields.Text := UTF8ToString(StringReplaceAll(URLDecode(FContext.InContent), '&', #13#10))
    else if IdemPChar(PUTF8Char(Context.InContentType), 'MULTIPART/FORM-DATA') then processMultiPartFormData;
  end;
  Result := FContentFields;
end;

function TSynWebEnv.MethodAndPathInfo: RawUTF8;
begin
  Result := Method + ':' + PathInfo;
end;

{$IFDEF UNICODE}
procedure TSynWebEnv.Redirect(const AURI: string);
begin
  Redirect(StringToUTF8( AURI));
end;

procedure TSynWebEnv.Redirect(const AURI: RawUTF8);
begin
  OutHeader('Location: ' + AURI);
  FStatusCode := 302;
end;


procedure TSynWebEnv.OutHtml(const AOutput: string);
begin
  OutHtml(StringToUTF8(AOutput));
end;

procedure TSynWebEnv.OutHtml(const AOutput: RawUTF8);
begin
  Context.OutContent := AOutput;
  Context.OutContentType := 'text/html; charset=utf-8';
end;

procedure TSynWebEnv.OutXML(const AOutput: string);
begin
  OutXML(StringToUTF8(AOutput));
end;

procedure TSynWebEnv.OutXML(const AOutput: RawUTF8);
begin
  Context.OutContent := AOutput;
  Context.OutContentType := 'text/xml; charset=utf-8';
end;
{$ELSE}
procedure TSynWebEnv.Redirect(const AURI: string);
begin
  OutHeader('Location: ' +StringToUTF8( AURI));
  FStatusCode := 302;
end;


procedure TSynWebEnv.OutHtml(const AOutput: string);
begin
  Context.OutContent := StringToUTF8(AOutput);
  Context.OutContentType := 'text/html; charset=utf-8';
end;

procedure TSynWebEnv.OutXML(const AOutput: string);
begin
  Context.OutContent := StringToUTF8(AOutput);
  Context.OutContentType := 'text/xml; charset=utf-8';
end;

{$ENDIF}

procedure TSynWebEnv.OutJSon(const AOutput: PDocVariantData);
begin
  OutJSon(AOutput.ToJson);
end;

procedure TSynWebEnv.OutJSon(const AOutput: RawUTF8);
begin
  Context.OutContent := AOutput;
  Context.OutContentType := 'application/json; charset=utf-8';
end;

procedure TSynWebEnv.OutHeader(const ANewHeaderAppended: RawUTF8);
begin
  if Length(ANewHeaderAppended) > 0 then begin
    with FContext do begin
      if Length(OutCustomHeaders) > 0 then OutCustomHeaders := OutCustomHeaders + #13#10;
      OutCustomHeaders := OutCustomHeaders + ANewHeaderAppended;
    end;
  end;
end;

procedure TSynWebEnv.OutFile(const AFileName: string);
var
  ContentType: RawUTF8;
begin
  Context.OutContent := StringToUTF8(AFileName);
  Context.OutContentType := HTTP_RESP_STATICFILE;
  ContentType := InferContentType(AFileName);
  if Length(ContentType) > 0 then begin
    OutHeader(HEADER_CONTENT_TYPE + ContentType);
  end;

end;

function TSynWebEnv.GetHeader(const AUpKey: RawUTF8; const ASource: RawUTF8 = ''; const Sep: AnsiChar = #13): RawUTF8;
var
  P, pUpKey, pSource: PUTF8Char;
  cVal: RawUTF8;
begin
  pUpKey := PUTF8Char(AUpKey);
  if ASource = '' then pSource := PUTF8Char(FContext.InHeaders)
  else pSource := PUTF8Char(ASource);
  P := StrPosI(pUpKey, pSource);
  if IdemPCharAndGetNextItem(P, pUpKey, cVal, Sep) then Result := Trim(cVal)
  else Result := '';
end;

constructor TSynWebEnv.Create(const AContext: THttpServerRequest);
var
  nQPos, nAPos: Integer;
begin
  FStatusCode := 200;
  FQueryFields := TStringList.Create;
  FContentFields := TStringList.Create;
  FContext := AContext;
  FHost := GetHeader('HOST:');
  FRemoteIP := UTF8ToString(GetHeader('REMOTEIP:'));
  FMethod := FContext.Method;
  FURL := PrepareURL;
  nAPos := {$IFDEF UNICODE}SynCommons.Pos{$ELSE}Pos{$ENDIF}('#', FURL);
  nQPos := {$IFDEF UNICODE}SynCommons.Pos{$ELSE}Pos{$ENDIF}('?', FURL);
  if nQPos > 0 then begin
    FPathInfo := copy(FURL, 1, nQPos - 1);
    if nAPos > nQPos then begin
      FQueryString := copy(FURL, nQPos + 1, nAPos - nQPos - 1);
      FAnchor := copy(FURL, nAPos + 1, Length(FURL) - nAPos);
    end else begin
      FQueryString := copy(FURL, nQPos + 1, Length(FURL) - nQPos);
      FAnchor := '';
    end;
  end else begin
    FQueryString := '';
    if nAPos > 0 then begin
      FPathInfo := copy(FURL, 1, nAPos - 1);
      FAnchor := copy(FURL, nAPos + 1, Length(FURL) - nAPos);
    end else begin
      FPathInfo := FURL;
      FAnchor := '';
    end;
  end;
  if Length(FQueryString) > 0 then
    FQueryFields.Text := UTF8ToString(StringReplaceAll(URLDecode(FQueryString), '&', #13#10));
end;

destructor TSynWebEnv.Destroy;
begin
  FContentFields.Free;
  FQueryFields.Free;
  inherited;
end;

function TSynWebEnv.PrepareURL: RawUTF8;
begin
  Result := Context.URL;
end;

procedure TSynWebEnv.OutStream(const AStream: TStream; const AContentType: RawUTF8 = '');
var
  Buffer: SockString;
begin
  SetLength(Buffer, AStream.Size);
  AStream.Read(Buffer[1], AStream.Size);
  Context.OutContent := Buffer;
  if Length(AContentType) > 0 then
    Context.OutContentType := AContentType;
end;

procedure TSynWebEnv.processMultiPartFormData;
begin

end;


initialization

finalization
  SetLength(RouteMapList, 0);

end.

