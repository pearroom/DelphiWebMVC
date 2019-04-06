{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       ∞Ê»®À˘”– (C) 2019 À’–À”≠(PRSoft)                }
{                                                       }
{*******************************************************}
unit RedisM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, Winapi.ActiveX,
  IdComponent, IdTCPConnection, IdTCPClient, IdGlobal, System.Win.ScktComp;

var
  Redis_IP: string;
  Redis_Port: Integer;
  Redis_PassWord: string;
  Redis_InitSize: integer;
  Redis_TimerOut: integer;

type
  TRedisM = class
  private
    TcpClient: TIdTCPClient;
    isConn: Boolean;
  public
    procedure setKey(key: string; value: string; timerout: Integer = 0);
    procedure delKey(key: string);
    function getKey(key: string): string;
    function tryconn(): Boolean;
    procedure freetcp;
    procedure setExpire(key: string; timerout: Integer);
    constructor Create();
    destructor Destroy; override;
  end;

implementation

uses
  LogUnit;

{ TRedis }

constructor TRedisM.Create();
begin
  TcpClient := nil;
  tryconn();
end;

procedure TRedisM.delKey(key: string);
begin
  if not isConn then
    if not tryconn then
      exit;
  with TcpClient do
  begin
    Socket.WriteLn('Del ' + key, IndyTextEncoding(IdTextEncodingType.encUTF8));
    Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
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

function TRedisM.getKey(key: string): string;
var
  s: string;
begin
  Result := '';
  if not isConn then
    if not tryconn then
      exit;

  try
    with TcpClient do
    begin

      Socket.WriteLn('get ' + key, IndyTextEncoding(IdTextEncodingType.encUTF8));
      s := Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
      Result := Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
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
      TcpClient.ReadTimeout := 30000;
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
              log('Redis∑˛ŒÒµ«¬º ß∞‹«ÎºÏ≤‚µ«¬º√‹¬Î');
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
          log('Redis∑˛ŒÒ¡¨Ω” ß∞‹');
        end;
      end;

    except
      on e: Exception do
      begin
        isConn := false;
        log(e.Message);
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

procedure TRedisM.setKey(key, value: string; timerout: Integer = 0);
var
  s: string;
begin
  if not isConn then
    if not tryconn then
      exit;

  try
    tcpclient.Socket.WriteLn('set ' + key + ' ' + value, IndyTextEncoding(IdTextEncodingType.encUTF8));
    s := tcpclient.Socket.ReadLn(IndyTextEncoding(IdTextEncodingType.encUTF8));
    if timerout > 0 then
      setExpire(key, timerout * 60)
    else
      setExpire(key, Redis_TimerOut * 60)
  except
    on e: Exception do
    begin
      log(e.Message);
    end;

  end;

end;

end.

