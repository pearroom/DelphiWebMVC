unit LogUnit;

interface

uses
  System.SysUtils, System.Rtti, System.Classes, Web.HTTPApp, uConfig,
  System.DateUtils,Vcl.StdCtrls;

procedure log(msg: string);

function readlog(var str: TMemo;var msg:string): boolean;

implementation

function readlog(var str: TMemo;var msg:string): boolean;
var
  logfile: string;
begin
  Result := false;
  logfile := WebApplicationDirectory + 'log\';
  if not DirectoryExists(logfile) then
  begin
    CreateDir(logfile);
  end;
  logfile := logfile + 'log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';
  if FileExists(logfile) then
  begin
    try
      str.Lines.LoadFromFile(logfile);
      Result := true;
    except
      msg:=logfile+'未找到日期文件';
      Result := false;
    end;

  end;
end;

procedure log(msg: string);
var
  log: string;
  logfile: string;
  tf: TextFile;
  fi: THandle;
begin
  if open_log then
  begin
  //  CoInitialize(nil);
    try
      log := FormatDateTime('yyyy-MM-dd hh:mm:ss', Now) + #13#10 + msg;
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
end;

end.

