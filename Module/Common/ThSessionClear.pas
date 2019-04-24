{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       版权所有 (C) 2019 苏兴迎(PRSoft)                }
{                                                       }
{*******************************************************}
unit ThSessionClear;

interface

uses
  System.Classes, System.SysUtils, uConfig, Command;

type
  TThSessionClear = class(TThread)
  private
    procedure clearMap;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    isstop: boolean;
  end;

implementation

uses
  LogUnit;

{ TThSession }
procedure TThSessionClear.clearMap();
var
  i: integer;
  k: integer;
  key, s: string;
begin
  try
    if SessionListMap <> nil then
    begin
      for key in SessionListMap.SessionLs_timerout.Keys do
      begin
        s := SessionListMap.SessionLs_timerout.Items[key];
        if s.Trim <> '' then
        begin
          if Now() >= StrToDateTime(s) then
          begin
            if SessionListMap.deleteSession(key) then
            begin
            //  log('清理Session-' + key);
              break;
            end;

          end;
        end;
      end;

    end;
  except
    Exit;
  end;
end;

procedure TThSessionClear.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    Sleep(100);
    Inc(k);
    if k >= 100 then
    begin
      k := 0;
      clearMap;

    end;

  end;
end;

end.

