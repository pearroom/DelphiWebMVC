{ *************************************************************************** }
{ SynWebEnv.pas is the 1st file of SynBroker Project                          }
{ by c5soft@189.cn  Version 0.9.2.0  2018-6-7                                 }
{ *************************************************************************** }
unit CrossWebEnv;

interface

uses Classes, SysUtils, CrossCommon,Net.CrossHttpServer, Net.CrossHttpParams,HTTPApp, Web.HTTPProd, Web.ReqMulti;
type
  SockString = type RawByteString;
  TCrossWebEnv = class
  protected
    FHost, FMethod, FURL, FPathInfo, FQueryString, FAnchor: RawUTF8;
    FSSL: Boolean;
    FStatusCode: Integer;
    fOutContent: SockString;
    FRemoteIP: string;
//    FContext: THttpServerRequest;
    FRequest: ICrossHttpRequest;
    FResponse: ICrossHttpResponse;
    FQueryFields: TStrings;
    FContentFields: TStrings;
    FOutPutstream:TStream;
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
    property OutContent: SockString read fOutContent write fOutContent ;
    property OutPutstream:TStream read fOutPutstream ;
    function GetHeader(const AUpKey: RawUTF8): RawUTF8;
    constructor Create(const ARequest: ICrossHttpRequest; AResponse: ICrossHttpResponse);
    destructor Destroy; override;
    function MethodAndPathInfo: RawUTF8;
    function GetRawContent: TBytes;
    procedure OutStream(const AStream: TStream; const AContentType: RawUTF8 = '');
    procedure OutFile(const AFileName: string);
    procedure OutHeader(const ANewHeaderAppended: RawUTF8);
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

  TDispatchAction = function(const AEnv: TCrossWebEnv): Boolean;

procedure RouteMap(const Method, PathInfo: RawUTF8; const Action: TDispatchAction);
function RouteDispatch(const AEnv: TCrossWebEnv; AMethodAndPathInfo: RawUTF8 = ''): Boolean;

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

function RouteDispatch(const AEnv: TCrossWebEnv; AMethodAndPathInfo: RawUTF8 = ''): Boolean;
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

{ TCrossWebEnv }

function InferContentType(const AFileName: string): RawUTF8;
var
  cExt: string;
begin
  Result := '';
  cExt := SysUtils.UpperCase(ExtractFileExt(AFileName));
  if (cExt = '.HTML') or (cExt = '.HTM') then Result := 'text/html; charset=UTF-8'
  else if cExt = '.JPG' then Result := 'image/jpeg'
  else if cExt = '.PNG' then Result := 'image/png'
  else if cExt = '.GIF' then Result := 'image/gif'
  else if cExt = '.ICO' then Result := 'image/x-icon'
  else if cExt = '.JS' then Result := 'application/x-javascript'
  else if cExt = '.CSS' then Result := 'text/css'
  else Result := 'application/octet-stream';
end;

function TCrossWebEnv.GetContentFields: TStrings;
begin
  if FContentFields.Count = 0 then begin
    if IdemPChar(PUTF8Char(StringToUTF8(Request.ContentType)), 'APPLICATION/X-WWW-FORM-URLENCODED') then
      FContentFields.Text := UTF8ToString(StringReplaceAll(TEncoding.UTF8.GetString(GetRawContent), '&', #13#10))
    else if IdemPChar(PUTF8Char(FRequest.ContentType), 'MULTIPART/FORM-DATA') then processMultiPartFormData;
  end;
  Result := FContentFields;
end;

function TCrossWebEnv.MethodAndPathInfo: RawUTF8;
begin
  Result := Method + ':' + PathInfo;
end;

{$IFDEF UNICODE}
procedure TCrossWebEnv.Redirect(const AURI: string);
begin
  Redirect(StringToUTF8( AURI));
end;

procedure TCrossWebEnv.Redirect(const AURI: RawUTF8);
begin
  OutHeader('Location: ' + AURI);
  FStatusCode := 302;
end;


procedure TCrossWebEnv.OutHtml(const AOutput: string);
begin
  OutHtml(StringToUTF8(AOutput));
end;

procedure TCrossWebEnv.OutHtml(const AOutput: RawUTF8);
begin
  Context.ContentType := 'text/html; charset=utf-8';
  OutContent :=AOutput;
end;

procedure TCrossWebEnv.OutXML(const AOutput: string);
begin
  OutContent :=StringToUTF8(AOutput);
end;

procedure TCrossWebEnv.OutXML(const AOutput: RawUTF8);
begin
  Context.ContentType := 'text/xml; charset=utf-8';
  OutContent :=AOutput;
end;
{$ELSE}
procedure TCrossWebEnv.Redirect(const AURI: string);
begin
  OutHeader('Location: ' +StringToUTF8( AURI));
  FStatusCode := 302;
end;


procedure TCrossWebEnv.OutHtml(const AOutput: string);
begin
  Context.OutContentType := 'text/html; charset=utf-8';
  OutContent :=StringToUTF8(AOutput);
end;

procedure TCrossWebEnv.OutXML(const AOutput: string);
begin
  Context.OutContentType := 'text/xml; charset=utf-8';
  OutContent :=StringToUTF8(AOutput);
end;

{$ENDIF}

procedure TCrossWebEnv.OutJSon(const AOutput: RawUTF8);
begin
  Context.ContentType := 'application/json; charset=utf-8';
  OutContent :=StringToUTF8(AOutput);
end;

procedure TCrossWebEnv.OutHeader(const ANewHeaderAppended: RawUTF8);
begin
  if Length(ANewHeaderAppended) > 0 then begin
    with Context do begin
      Header.Decode(ANewHeaderAppended,false);
    end;
  end;
end;

procedure TCrossWebEnv.OutFile(const AFileName: string);
var
  ContentType: RawUTF8;
const
HTTP_RESP_STATICFILE = '!STATICFILE';
HEADER_CONTENT_TYPE = 'Content-Type: ';
begin
  Context.ContentType := HTTP_RESP_STATICFILE;
  ContentType := InferContentType(AFileName);
  if Length(ContentType) > 0 then begin
    OutHeader(HEADER_CONTENT_TYPE + ContentType);
  end;
  OutContent :=AFileName;
end;

function TCrossWebEnv.GetHeader(const AUpKey: RawUTF8): RawUTF8;
var
  P, pUpKey, pSource: PUTF8Char;
  cVal: RawUTF8;
begin
  result := FRequest.GetHeader.Params[AUpKey];
//  pUpKey := PUTF8Char(AUpKey);
//  if ASource = '' then pSource := PUTF8Char(StringToUTF8(Request.Header.Encode))
//  else pSource := PUTF8Char(ASource);
//  P := StrPosI(pUpKey, pSource);
//  if IdemPCharAndGetNextItem(P, pUpKey, cVal, Sep) then Result := Trim(cVal)
//  else Result := '';
end;

function TCrossWebEnv.GetRawContent: TBytes;
var
  vFormField:TBytes;
  i:Integer;
  vlen:UInt64;
  vstr:string;
begin
  case Request.GetBodyType of
    btNone:
    begin
      Result := nil;
    end;
    btMultiPart:
    begin
       SetLength(result,TBytesStream(Request.Body).Size);
       TBytesStream(Request.Body).position := 0;
       TBytesStream(Request.Body).Read(result[0],TBytesStream(Request.Body).Size);
    end;
    btUrlEncoded:
    begin
      result := TEncoding.UTF8.GetBytes(THttpUrlParams(Request.Body).Encode);
    end;
    btBinary:
    begin
       SetLength(result,TBytesStream(Request.Body).Size);
       TBytesStream(Request.Body).position := 0;
       TBytesStream(Request.Body).Read(result[0],TBytesStream(Request.Body).Size);
    end;
  end;
end;

constructor TCrossWebEnv.Create(const ARequest: ICrossHttpRequest; AResponse: ICrossHttpResponse);
var
  nQPos, nAPos: Integer;
begin
  FStatusCode := 200;
  FQueryFields := TStringList.Create;
  FContentFields := TStringList.Create;
  FRequest := ARequest;
  FResponse := AResponse;
  FHost := GetHeader('HOST');
 // FRemoteIP := UTF8ToString(GetHeader('REMOTEIP'));
  FRemoteIP:=ARequest.Connection.PeerAddr;
  FMethod := StringToUTF8(FRequest.Method);
  FURL := PrepareURL;
  nAPos := Pos('#', FURL);
  nQPos := Pos('?', FURL);
  FPathInfo := ARequest.path;
  FQueryString := ARequest.Query.Encode;
//  FQueryString := Copy(FQueryString,1,Length(FQueryString)-2);
  FAnchor := '';
//  if nQPos > 0 then begin
//    FPathInfo := copy(FURL, 1, nQPos - 1);
//    if nAPos > nQPos then begin
//      FQueryString := copy(FURL, nQPos + 1, nAPos - nQPos - 1);
//      FAnchor := copy(FURL, nAPos + 1, Length(FURL) - nAPos);
//    end else begin
//      FQueryString := copy(FURL, nQPos + 1, Length(FURL) - nQPos);
//      FAnchor := '';
//    end;
//  end else begin
//    if nAPos > 0 then begin
//      FAnchor := copy(FURL, nAPos + 1, Length(FURL) - nAPos);
//    end else begin
//      FPathInfo := FURL;
//      FAnchor := '';
//    end;
//  end;

  FQueryFields.Text := ARequest.Query.Encode;

end;

destructor TCrossWebEnv.Destroy;
begin
  FContentFields.Free;
  FQueryFields.Free;
  inherited;
end;

function TCrossWebEnv.PrepareURL: RawUTF8;
begin
  Result := StringToUTF8(FRequest.RawPathAndParams);
end;

procedure TCrossWebEnv.OutStream(const AStream: TStream; const AContentType: RawUTF8 = '');
begin
  if AStream.Size >0 then
    begin
      if not Assigned(FOutPutstream) then
        begin
          FOutPutstream := TMemoryStream.Create;
        end;  
      AStream.Position := 0;
      FOutPutstream.CopyFrom(AStream,AStream.Size);
      if Length(AContentType) > 0 then
        Context.ContentType := AContentType;
    end;  
end;

procedure TCrossWebEnv.processMultiPartFormData;
begin

end;


initialization

finalization
  SetLength(RouteMapList, 0);

end.

