{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit LogUnit;

interface

uses
  System.SysUtils, System.Rtti, System.Classes, Web.HTTPApp, uConfig, System.DateUtils,
  Vcl.StdCtrls;

procedure log(msg: string);

function readlog(var str: TMemo; var msg: string): boolean;

type
  TLogTh = class(TThread)
  public
    procedure writelog(msg: string);
  protected
    procedure Execute; override;
  end;

implementation

uses
  command;

function readlog(var str: TMemo; var msg: string): boolean;
var
  logfile: string;
begin
  Result := false;
  if open_log then
  begin
    logfile := WebApplicationDirectory + 'log\';
    if not DirectoryExists(logfile) then
    begin
      CreateDir(logfile);
    end;
    logfile := logfile + 'log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';
    if FileExists(logfile) then
    begin
      str.Lines.LoadFromFile(logfile);
      Result := true;
    end
    else
    begin
      msg := logfile + '未找到日志文件';
      Result := false;
    end;
  end
  else
  begin
    msg := '日志功能未开启';
    Result := false;
  end;
end;

procedure log(msg: string);
begin
  if open_log then
  begin
    _LogList.Add(msg);
  end;
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
    logfile := WebApplicationDirectory + 'log\';
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
    CloseFile(tf);

  finally
   //   CoUnInitialize;
  end;
end;

end.

