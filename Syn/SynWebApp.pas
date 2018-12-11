{ *************************************************************************** }
{  SynWebApp.pas is the 4th file of SynBroker Project                         }
{  by c5soft@189.cn  Version 0.9.1.0  2018-6-2                                }
{ *************************************************************************** }

{$DENYPACKAGEUNIT}

unit SynWebApp;

interface

uses Classes, SysUtils, WebBroker, HTTPApp, SynCommons, SynCrtSock,SynWebServer;


type

  TSynWebApplication = class(TWebApplication)
  private
    fServer: TSynWebServer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Run; override;
  end;


implementation

uses Windows, BrkrConst, IniFiles, SynZip, SynWebReqRes;


procedure WaitForEscKey;
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
begin
  LHandle := GetStdHandle(STD_INPUT_HANDLE);
  while True do begin
    Win32Check(ReadConsoleInput(LHandle, LInputRecord, 1, LEvent));
    if (LInputRecord.EventType = KEY_EVENT) and
      LInputRecord.Event.KeyEvent.bKeyDown and
      (LInputRecord.Event.KeyEvent.wVirtualKeyCode = VK_ESCAPE) then
      break;
  end;
end;


{ TSynWebApplication }

constructor TSynWebApplication.Create(AOwner: TComponent);
begin
  inherited;
  fServer:=TSynWebServer.Create(Self);
end;

destructor TSynWebApplication.Destroy;
begin
  fServer.Free;
  inherited;
end;



procedure TSynWebApplication.Run;
begin
  WriteLn('Server Listening on http://localhost:' + fServer.Port + ' ...');
  WriteLn('Press ESC to quit');
  WaitForEscKey;
end;

procedure InitApplication;
begin
  Application := TSynWebApplication.Create(nil);
end;


initialization
  InitApplication;
end.

