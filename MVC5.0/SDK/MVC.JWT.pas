{ ******************************************************* }
{ }
{ DelphiWebMVC 5.0 }
{ E-Mail:pearroom@yeah.net }
{ 版权所有 (C) 2022-2 苏兴迎(PRSoft) }
{ }
{ ******************************************************* }
// 第三方模块可以参考本模块开发
unit MVC.JWT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.JSON, System.Generics.Collections, IdURI, IdGlobal,
  IdCoderMIME, EncdDecd, IdHMACSHA1, IdSSLOpenSSL, MVC.LogUnit,
  IdHashMessageDigest, IdHash;

type
  TJWT = class
  private
    claimList: TDictionary<string, string>;
    FExpiration: string;
    Fsign: string;
    FHeader: string;
    FSubject: string;
    FId: string;
    FIssuedAt: string;
    FPayload: string;
    FAudience: string;
    FIssuer: string;
    FNotBefore: string;
    procedure SetExpiration(const Value: string);
    procedure SetHeader(const Value: string);
    procedure SetId(const Value: string);
    procedure SetIssuedAt(const Value: string);
    procedure SetPayload(const Value: string);
    procedure Setsign(const Value: string);
    procedure SetSubject(const Value: string);
    function Base64Decode(S: string): string;
    function Base64Encode(S: string): string;
    function Base64EncodeByte(S: Tidbytes): string;
    procedure parserHeader();
    procedure parserPayLoad();
    procedure SetAudience(const Value: string);
    procedure SetIssuer(const Value: string);
    procedure SetNotBefore(const Value: string);
  public
    property NotBefore: string read FNotBefore write SetNotBefore;
    property Issuer: string read FIssuer write SetIssuer;
    property Audience: string read FAudience write SetAudience;
    property Id: string read FId write SetId;
    property Subject: string read FSubject write SetSubject;
    property IssuedAt: string read FIssuedAt write SetIssuedAt;
    property Expiration: string read FExpiration write SetExpiration;
    property Header: string read FHeader write SetHeader;
    property Payload: string read FPayload write SetPayload;
    property sign: string read Fsign write Setsign;
    procedure claimAdd(key, Value: string);
    function claimGet(key: string): string;
    function compact(): string;
    function parser(sign, Value: string): Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  IJWT = interface // 接口实现类将自动释放
    function O: TJWT; // 开放外部调用方法
  end;

  TJWTObject = class(TInterfacedObject, IJWT) // 需要继承接口类，和接口
  private
    sJWT: TJWT;
  public
    function O: TJWT;
    constructor Create;
    destructor Destroy; override;
  end;

function IIJWT: TJWTObject;

function JWT_Init: Boolean;

implementation

function IIJWT: TJWTObject;
var
  err: string;
begin
  if JWT_Init then
    Result := TJWTObject.Create as TJWTObject
  else
  begin
    err := '缺少ssleay32.dll,libeay32.dll,msvcr110.dll;JWT功能无法使用';
    raise Exception.Create(err);
    Result := nil;
  end;
end;
{ TJWTBuilder }

function JWT_Init: Boolean;
begin
     // IdSSLOpenSSL.UnLoadOpenSSLLibrary;
  if not IdSSLOpenSSL.LoadOpenSSLLibrary then
  begin
    log('缺少ssleay32.dll,libeay32.dll,msvcr110.dll;JWT功能无法使用');
    Result := false;
  end
  else
    Result := true;
end;

function TJWT.Base64Decode(S: string): string;
var
  base64: TIdDeCoderMIME;
  // tmpBytes: TBytes;
begin
  Result := S;
  base64 := TIdDeCoderMIME.Create(nil);
  try
    base64.FillChar := '=';
    // tmpBytes := TBytes(base64.DecodeBytes(S));
    // Result := TEncoding.UTF8.GetString(tmpBytes);
    Result := base64.DecodeString(S);
  finally
    base64.Free;
  end;
end;

function TJWT.Base64Encode(S: string): string;
var
  base64: TIdEncoderMIME;
  // tmpBytes: TBytes;
begin
  base64 := TIdEncoderMIME.Create(nil);
  try
    base64.FillChar := '=';
    Result := base64.EncodeString(S);
    // tmpBytes := TEncoding.UTF8.GetBytes(S);
    // Result := base64.EncodeBytes(TIdBytes(tmpBytes));
  finally
    base64.Free;
  end;
end;

function TJWT.Base64EncodeByte(S: Tidbytes): string;
var
  base64: TIdEncoderMIME;
  // tmpBytes: TBytes;
begin
  base64 := TIdEncoderMIME.Create(nil);
  try
    base64.FillChar := '=';
    // Result := base64.EncodeString(S);
    // tmpBytes := TEncoding.UTF8.GetBytes(S);
    Result := base64.EncodeBytes(S);
  finally
    base64.Free;
  end;
end;

procedure TJWT.claimAdd(key, Value: string);
begin
  claimList.TryAdd(key, Value);
end;

function TJWT.claimGet(key: string): string;
var
  Value: string;
begin
  self.claimList.TryGetValue(key, Value);
  Result := Value;
end;

function TJWT.compact: string;
var
  headjson, Payloadjson: TJSONObject;
  key, v: string;
  ret, ret2: Tidbytes;
  token: string;
begin

  headjson := TJSONObject.Create;
  headjson.AddPair('typ', 'JWT');
  headjson.AddPair('alg', 'HS256');
  Header := headjson.ToJSON;
  headjson.Free;

  // Payload
  Payloadjson := TJSONObject.Create;
  with Payloadjson do
  begin
    if Subject <> '' then
      AddPair('sub', Subject);
    if Expiration <> '' then
      AddPair('exp', Expiration);
    if Id <> '' then
      AddPair('jti', Id);
    if IssuedAt <> '' then
      AddPair('iat', IssuedAt);
    if Audience <> '' then
      AddPair('aud', Audience);
    if Issuer <> '' then
      AddPair('iss', Issuer);
    if NotBefore <> '' then
      AddPair('nbf', NotBefore);
    for key in claimList.Keys do
    begin
      if claimList.TryGetValue(key, v) then
        AddPair(key, v);
    end;
    Payload := ToJSON;
    Free;
  end;

  with TIdHMACSHA256.Create do
  begin
    try
      try
        key := ToBytes(sign);
        token := Base64Encode(Header) + '.' + Base64Encode(Payload);
        ret := ToBytes(token);
        ret2 := HashValue(ret);
        Result := token + '.' + Base64EncodeByte(ret2);
      except
        begin
          Result := '';
        end;
      end;
    finally
      Free;
    end;
  end;
end;

constructor TJWT.Create;
begin
  claimList := TDictionary<string, string>.Create;
end;

destructor TJWT.Destroy;
begin
  claimList.Clear;
  claimList.Free;
  inherited;
end;

function TJWT.parser(sign, Value: string): Boolean;
var
  ret, ret2: Tidbytes;
  SH256: TIdHMACSHA256;
  tmp: TStringList;
  body: string;
  head: string;
  sgin_: string;
begin
  self.sign := sign;
  SH256 := TIdHMACSHA256.Create;
  tmp := TStringList.Create;
  try
    try
      tmp.Delimiter := '.';
      tmp.DelimitedText := Value;
      if tmp.Count <> 3 then
      begin
        // Result := false;
        exit(False);
      end;
      head := tmp[0];
      body := tmp[1];
      sgin_ := tmp[2];

      with SH256 do
      begin
        key := ToBytes(sign);
        ret := ToBytes(head + '.' + body);
        ret2 := HashValue(ret);
        if Base64EncodeByte(ret2) = sgin_ then
        begin
          Header := Base64Decode(head);
          Payload := Base64Decode(body);
          parserHeader;
          parserPayLoad;
          Result := true;
        end
        else
        begin
          Result := False;
        end;
      end;
    except
      Result := False;
    end;
  finally
    tmp.Free;
    SH256.Free;
  end;
end;

procedure TJWT.parserHeader;
begin

end;

procedure TJWT.parserPayLoad;
var
  PayJson: TJSONObject;
  JSONPair: TJSONPair;
begin
  claimList.Clear;
  PayJson := TJSONObject.ParseJSONValue(Payload) as TJSONObject;
  try
    for JSONPair in PayJson do
    begin
      if JSONPair.JsonString.Value = 'jti' then
        Id := JSONPair.JsonValue.Value
      else if JSONPair.JsonString.Value = 'sub' then
        Subject := JSONPair.JsonValue.Value
      else if JSONPair.JsonString.Value = 'iat' then
        IssuedAt := JSONPair.JsonValue.Value
      else if JSONPair.JsonString.Value = 'exp' then
        Expiration := JSONPair.JsonValue.Value
      else if JSONPair.JsonString.Value = 'aud' then
        Audience := JSONPair.JsonValue.Value
      else if JSONPair.JsonString.Value = 'iss' then
        Issuer := JSONPair.JsonValue.Value
      else if JSONPair.JsonString.Value = 'nbf' then
        NotBefore := JSONPair.JsonValue.Value
      else
      begin
        claimList.TryAdd(JSONPair.JsonString.Value, JSONPair.JsonValue.Value);
      end;
    end;
  finally
    PayJson.Free;
  end;
end;

procedure TJWT.SetAudience(const Value: string);
begin
  FAudience := Value;
end;

procedure TJWT.SetExpiration(const Value: string);
begin
  FExpiration := Value;
end;

procedure TJWT.SetHeader(const Value: string);
begin
  FHeader := Value;
end;

procedure TJWT.SetId(const Value: string);
begin
  FId := Value;
end;

procedure TJWT.SetIssuedAt(const Value: string);
begin
  FIssuedAt := Value;
end;

procedure TJWT.SetIssuer(const Value: string);
begin
  FIssuer := Value;
end;

procedure TJWT.SetNotBefore(const Value: string);
begin
  FNotBefore := Value;
end;

procedure TJWT.SetPayload(const Value: string);
begin
  FPayload := Value;
end;

procedure TJWT.Setsign(const Value: string);
begin
  Fsign := Value;
end;

procedure TJWT.SetSubject(const Value: string);
begin
  FSubject := Value;
end;

{ TJWTObject }

constructor TJWTObject.Create;
begin
  sJWT := TJWT.Create;
end;

destructor TJWTObject.Destroy;
begin
  sJWT.Free;
  inherited;
end;

function TJWTObject.O: TJWT;
begin
  Result := sJWT;
end;

end.

