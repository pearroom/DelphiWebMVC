{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.LogUnit;
{$I mvc.inc}

interface

uses
  Winapi.Windows, System.SysUtils,
  {$IFDEF MSWINDOWS}vcl.forms, {$ENDIF}
  System.Classes, Web.HTTPApp, MVC.Tool;

type
  TLogThread = class(TThread)
  private
    procedure Write(msg: string);
  protected
    procedure Execute; override;
  public
    LogList: TStringList;
    constructor Create;
    destructor Destroy; override;
  end;

var
  logThread: TLogThread;


procedure Log(msg: string);

procedure LogDebug(msg: string);

procedure WriteLog(msg: string);

implementation

uses
  MVC.Config;

procedure WriteLog(msg: string);
begin
  Lock(logThread.LogList);
  logThread.Write(msg);
  UnLock(logThread.LogList);
end;

procedure log(msg: string);
begin
  if config.open_log then
    logThread.LogList.Add(msg);
end;

procedure LogDebug(msg: string);
begin
{$IFDEF LOGDEBUG}
  logThread.LogList.Add(msg);
{$ENDIF}
end;

{ TLogTh }

constructor TLogThread.Create;
begin
  inherited Create(False);
  LogList := TStringList.Create;
end;

destructor TLogThread.Destroy;
begin
  LogList.Free;
  inherited;
end;

procedure TLogThread.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    Sleep(10);
    Inc(k);
    if k >= 100 then
    begin
      k := 0;
      if LogList.Count > 0 then
      begin
        Lock(LogList);
        Write(LogList.Strings[0]);
        LogList.Delete(0);
        UnLock(LogList);

      end;
    end;
  end;
end;

procedure TLogThread.Write(msg: string);
var
  log: string;
  logfile: string;
  tf: TextFile;
  fi: THandle;
begin

  try
    log := FormatDateTime('yyyy-MM-dd hh:mm:ss', Now) + '  ' + msg;
    logfile := WebApplicationDirectory + 'Log/';
    logfile := IITool.PathFmt(logfile);
    if not DirectoryExists(logfile) then
    begin
      CreateDir(logfile);
    end;
    logfile := logfile + 'Log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';

    AssignFile(tf, logfile);
    if FileExists(logfile) then
    begin
      Append(tf);
    end
    else
    begin
      fi := FileCreate(logfile);
      FileClose(fi);
      Rewrite(tf);
    end;
    Writeln(tf, log);
    Flush(tf);
  finally
    CloseFile(tf);
  end;
//  {$IFDEF CONSOLE}
//  Writeln(log);
//  {$ENDIF}
end;

initialization
  logThread := TLogThread.Create;


finalization
  logThread.Free;

end.

