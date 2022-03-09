{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.LogUnit;

interface

uses
 {$IFDEF WINFORM}      vcl.forms, Winapi.Windows, {$ENDIF} System.SysUtils,
System.Classes, Web.HTTPApp, MVC.Config;

procedure log(msg: string);

type
  TLogTh = class(TThread)
  public
    procedure writelog(msg: string);
  protected
    procedure Execute; override;
  end;

var
  _LogList: TStringList = nil;
  _logThread: TLogTh = nil;

implementation

procedure log(msg: string);
begin
{$IFDEF WINFORM}
  _logThread.writelog(msg);
  Application.MessageBox(PChar(msg), '异常', MB_OK + MB_ICONSTOP);
{$ELSE}
  if Config.open_log then
  begin
    _LogList.Add(msg);
  end;
  {$ENDIF}
end;

{ TLogTh }

procedure TLogTh.Execute;
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
      if _LogList.Count > 0 then
      begin
        writelog(_LogList.Strings[0]);
        _LogList.Delete(0);
      end;
    end;
  end;
end;

procedure TLogTh.writelog(msg: string);
var
  log: string;
  logfile: string;
  tf: TextFile;
  fi: THandle;
begin
  try
    log := FormatDateTime('yyyy-MM-dd hh:mm:ss', Now) + '  ' + msg;
    logfile := WebApplicationDirectory + 'log/';
    if not DirectoryExists(logfile) then
    begin
      CreateDir(logfile);
    end;
    logfile := logfile + 'log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';

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
   //   CoUnInitialize;
  end;
end;

end.

