{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.RedisM;

interface

uses
  System.SysUtils, System.Variants, System.Classes, IdBaseComponent, IdCoderMIME,
  IdTCPConnection, IdTCPClient, IdGlobal, xsuperobject;

var
  Redis_IP: string;
  Redis_Port: Integer;
  Redis_PassWord: string;
  Redis_InitSize: integer;
  Redis_TimeOut: integer;
  Redis_ReadTimeOut: integer;

type
  TRedisM = class
  private
    TcpClient: TIdTCPClient;
    isConn: Boolean;
    function HexToStr(S: string): string;
    function StrToHex(S: string): string;
  public
    function setKeyText(key: string; value: string; timerout: Integer = 0): Boolean;
    function setKeyJSON(key: string; value: ISuperObject; timerout: Integer = 0): Boolean;
    function getKeyText(key: string): string;
    function getKeyJSON(key: string): ISuperObject;
    function getKeyCount: integer;
    function delKey(key: string): Boolean;
    function tryconn(): Boolean;
    procedure freetcp;
    procedure setExpire(key: string; timerout: Integer);
    constructor Create();
    destructor Destroy; override;
  end;

implementation

uses
  MVC.LogUnit;

{ TRedis }

constructor TRedisM.Create();
begin
  TcpClient := nil;
  tryconn();
end;

function TRedisM.StrToHex(S: string): string;
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

function TRedisM.HexToStr(S: string): string;
var
  base64: TIdDeCoderMIME;
 // tmpBytes: TBytes;
begin
  Result := S;
  base64 := TIdDecoderMIME.Create(nil);
  try
    base64.FillChar := '=';
   // tmpBytes := TBytes(base64.DecodeBytes(S));
    //Result := TEncoding.UTF8.GetString(tmpBytes);
    Result := base64.DecodeString(S);
  finally
    base64.Free;
  end;
end;

function TRedisM.delKey(key: string): Boolean;
var
  s: string;
begin
  Result := True;
  if not isConn then
    if not tryconn then
    begin
      Result := false;
      exit;
    end;

  try

    tcpclient.Socket.WriteLn('del ' + key, IndyTextEncoding(IdTextEncodingType.encUTF8));
    s := tcpclient.Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
  except
    on e: Exception do
    begin
      Result := False;
      log(e.Message);
    end;
  end;
end;

destructor TRedisM.Destroy;
begin
  freetcp;
  inherited;
end;

procedure TRedisM.freetcp;
begin
  try
    TcpClient.Disconnect;
  finally
    TcpClient.Free;
  end;
end;

function TRedisM.setKeyText(key, value: string; timerout: Integer = 0): Boolean;
var
  s: string;
begin
  Result := true;
  if not isConn then
    if not tryconn then
    begin
      Result := false;
      exit;
    end;

  try

    tcpclient.Socket.WriteLn('set ' + key + ' ' + value, IndyTextEncoding(IdTextEncodingType.encUTF8));
    s := tcpclient.Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
    if timerout > 0 then
      setExpire(key, timerout * 60)
    else
      setExpire(key, Redis_TimeOut * 60)
  except
    on e: Exception do
    begin
      Result := false;
      log(e.Message);
    end;
  end;
end;

function TRedisM.setKeyJSON(key: string; value: ISuperObject; timerout: Integer): Boolean;
begin
  Result := false;
  if value <> nil then
  begin
    Result := setKeyText(key, StrToHex(value.asjson), timerout);
  end;
end;

function TRedisM.getKeyCount: integer;
var
  s: string;
begin
  if not isConn then
    if not tryconn then
      exit;
  try
    with tcpclient do
    begin
      Socket.WriteLn('DBSIZE', IndyTextEncoding(IdTextEncodingType.encUTF8));
      s := Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
      if s <> '' then
        Result := StrToInt(Copy(s, 2, s.Length))
      else
        Result := -1;
    end;
  except
    on e: Exception do
    begin
      log(e.Message);
    end;
  end;
end;

function TRedisM.getKeyJSON(key: string): ISuperObject;
var
  txt: string;
begin
  Result := nil;
  if key.Trim <> '' then
  begin
    txt := getKeyText(key);
    if txt.Trim <> '' then
    begin
      Result := SO(HexToStr(txt));
    end
    else
      Result := so('{}');
  end;
end;

function TRedisM.getKeyText(key: string): string;
var
  s: string;
begin
  Result := '';
  if not isConn then
    if not tryconn then
    begin
      Result := '';
      exit;
    end;

  try
    with TcpClient do
    begin

      Socket.WriteLn('get ' + key, IndyTextEncoding(IdTextEncodingType.encUTF8));
      s := Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
      s := s.Replace('$', '');
      if StrToInt(s) > 0 then
      begin
        s := Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
      end
      else
      begin
        s := '';
      end;

      Result := s;
    end;
  except
    on e: Exception do
    begin
      log(e.Message);
    end;
  end;
end;

function TRedisM.tryconn: Boolean;
var
  s: string;
begin
  if TcpClient = nil then
    tcpclient := TIdTCPClient.Create(nil);
  try

    try
      tcpclient.Host := Redis_IP;
      tcpclient.Port := Redis_Port;
      TcpClient.ReadTimeout := Redis_ReadTimeOut * 1000;
      tcpclient.Connect;
      TcpClient.Socket.RecvBufferSize := 100 * 1024;
      TcpClient.Socket.SendBufferSize := 100 * 1024;

      with tcpclient do
      begin
        if Connected then
        begin
          if Redis_PassWord <> '' then
          begin
            Socket.WriteLn('AUTH ' + Redis_PassWord, IndyTextEncoding(IdTextEncodingType.encUTF8));
            s := Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
            if s = '+OK' then
            begin
              isConn := true;
            end
            else
            begin
              isConn := true;
              log('Redis服务登录失败请检测登录密码');
            end;
          end
          else
          begin
            isConn := true;
          end;
        end
        else
        begin
          isConn := false;
          log('Redis服务连接失败');
        end;
      end;
    except
      on e: Exception do
      begin
        isConn := false;
        log('Redis连接服务失败:' + e.Message);
      end;
    end;
  finally
    result := isConn;
  end;
end;

procedure TRedisM.setExpire(key: string; timerout: Integer);
var
  s: string;
begin
  if not isConn then
    if not tryconn then
      exit;
  try
    with tcpclient do
    begin
      Socket.WriteLn('expire ' + key + ' ' + inttostr(timerout), IndyTextEncoding(IdTextEncodingType.encUTF8));
      s := Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
    end;
  except
    on e: Exception do
    begin
      log(e.Message);
    end;
  end;
end;

end.

